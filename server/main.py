"""GOKO cloud KataGo analysis server.

Thin FastAPI wrapper around a long-running `katago analysis` subprocess.
Each HTTP request parses one SGF, asks KataGo to analyse every turn, and
returns one PositionEval per ply to the Flutter client (see
[lib/services/ai/analysis_client.dart]).

Run:
    export ZAIBAL_ANALYSIS_TOKEN=<your-random-secret>
    uvicorn main:app --host 0.0.0.0 --port 8080 --workers 1

Notes:
* `--workers 1`: the KataGo subprocess is global mutable state — multiple
  workers would race over stdin/stdout. To scale horizontally, run multiple
  uvicorn processes behind a load balancer with their own KataGo each.
* The wrapper uses an asyncio.Lock around stdin/stdout reads. This serialises
  requests through the engine. KataGo internally parallelises across CPU
  threads / GPU, so one engine is enough for tens of QPS on decent hardware.
* No moves are persisted; queries are stateless.
"""

from __future__ import annotations

import asyncio
import json
import os
import re
import secrets
import sys
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel

# ── Config ────────────────────────────────────────────────────────────────────

KATAGO_BIN = os.environ.get("KATAGO_BIN", "/usr/local/bin/katago")
KATAGO_MODEL = os.environ.get("KATAGO_MODEL", "/opt/katago/model.bin.gz")
KATAGO_CONFIG = os.environ.get(
    "KATAGO_CONFIG", "/opt/katago/analysis_example.cfg"
)
AUTH_TOKEN = os.environ.get("ZAIBAL_ANALYSIS_TOKEN", "")
if not AUTH_TOKEN:
    sys.stderr.write(
        "WARNING: ZAIBAL_ANALYSIS_TOKEN is empty — server will accept any "
        "bearer token. Set it before running in production.\n"
    )

# Defensive cap so a misbehaving client can't request a million-visit search.
MAX_VISITS_CAP = 1600


# ── KataGo subprocess wrapper ─────────────────────────────────────────────────


class KataGoEngine:
    """Owns the long-running KataGo `analysis` subprocess.

    KataGo's analysis mode speaks JSON over stdin/stdout. Each query is one
    JSON line in; one or more JSON lines out. We send one `analyseTurns`
    query per HTTP request and collect responses until we've seen one for
    every turn (or KataGo errors out).
    """

    def __init__(self) -> None:
        self.proc: asyncio.subprocess.Process | None = None
        self.lock = asyncio.Lock()
        self._next_id = 0

    async def start(self) -> None:
        self.proc = await asyncio.create_subprocess_exec(
            KATAGO_BIN,
            "analysis",
            "-model",
            KATAGO_MODEL,
            "-config",
            KATAGO_CONFIG,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

    async def stop(self) -> None:
        if self.proc and self.proc.returncode is None:
            self.proc.terminate()
            try:
                await asyncio.wait_for(self.proc.wait(), timeout=5)
            except asyncio.TimeoutError:
                self.proc.kill()

    async def analyse_game(
        self,
        moves: list[tuple[str, str]],
        board_size: int,
        komi: float,
        max_visits: int,
    ) -> list[dict[str, Any]]:
        """Run a multi-turn analysis.

        `moves` is a list of `(color, gtp_coord)` tuples ordered from move 1.
        Returns one dict per ply 0..len(moves), matching the
        [Flutter client's expected schema](analysis_client.dart).
        """
        if self.proc is None or self.proc.stdin is None or self.proc.stdout is None:
            raise RuntimeError("KataGo process not started")

        async with self.lock:
            self._next_id += 1
            query_id = f"q{self._next_id}"
            analyse_turns = list(range(0, len(moves) + 1))
            query = {
                "id": query_id,
                "moves": [[c, g] for c, g in moves],
                "rules": "chinese",
                "komi": komi,
                "boardXSize": board_size,
                "boardYSize": board_size,
                "analyzeTurns": analyse_turns,
                "maxVisits": max_visits,
                "includeOwnership": False,
                "includePolicy": False,
            }
            self.proc.stdin.write((json.dumps(query) + "\n").encode())
            await self.proc.stdin.drain()

            # Collect one response per requested turn.
            collected: dict[int, dict[str, Any]] = {}
            wanted = set(analyse_turns)
            while wanted:
                line = await asyncio.wait_for(
                    self.proc.stdout.readline(), timeout=120
                )
                if not line:
                    raise RuntimeError("KataGo closed its stdout")
                try:
                    resp = json.loads(line.decode().strip())
                except json.JSONDecodeError:
                    continue  # Skip any noisy log lines KataGo emits.
                if resp.get("id") != query_id:
                    continue
                if "error" in resp:
                    raise RuntimeError(f"KataGo error: {resp['error']}")
                turn = resp.get("turnNumber")
                if turn is None or turn not in wanted:
                    continue
                collected[turn] = resp
                wanted.discard(turn)

            return [
                _shape_response(collected[t], board_size)
                for t in sorted(collected)
            ]


engine = KataGoEngine()


@asynccontextmanager
async def lifespan(app: FastAPI):
    await engine.start()
    try:
        yield
    finally:
        await engine.stop()


app = FastAPI(title="GOKO Analysis", lifespan=lifespan)


# ── HTTP layer ────────────────────────────────────────────────────────────────


class AnalyseRequest(BaseModel):
    sgf: str
    maxVisits: int = 400


@app.get("/healthz")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/v1/analyse")
async def analyse(
    req: AnalyseRequest, authorization: str | None = Header(default=None)
) -> dict[str, Any]:
    if AUTH_TOKEN and not secrets.compare_digest(
        authorization or "", f"Bearer {AUTH_TOKEN}"
    ):
        raise HTTPException(401, detail="Invalid bearer token")
    if req.maxVisits < 1 or req.maxVisits > MAX_VISITS_CAP:
        raise HTTPException(
            400,
            detail=f"maxVisits must be between 1 and {MAX_VISITS_CAP}",
        )
    try:
        sgf_meta = _parse_sgf(req.sgf)
    except ValueError as e:
        raise HTTPException(400, detail=str(e))

    try:
        evals = await engine.analyse_game(
            moves=sgf_meta["moves"],
            board_size=sgf_meta["board_size"],
            komi=sgf_meta["komi"],
            max_visits=req.maxVisits,
        )
    except (RuntimeError, asyncio.TimeoutError) as e:
        raise HTTPException(503, detail=f"Engine failure: {e}")
    return {"evals": evals}


# ── SGF parsing & response shaping ────────────────────────────────────────────


_SGF_PROP_RE = re.compile(r"(?P<key>[A-Z]+)\[(?P<val>[^\]]*)\]")


def _parse_sgf(sgf: str) -> dict[str, Any]:
    """Minimal SGF parser: extracts SZ, KM, and the move sequence.

    Accepts the dialect emitted by `lib/utils/sgf_builder.dart`. Does NOT
    handle full SGF (variations, comments, escaped values) — that's overkill
    for our pipeline.
    """
    board_size = 19
    komi = 7.5
    moves: list[tuple[str, str]] = []
    # Iterate property tokens in source order; size/komi land before moves.
    for match in _SGF_PROP_RE.finditer(sgf):
        key = match.group("key")
        val = match.group("val")
        if key == "SZ":
            try:
                board_size = int(val.split(":")[0])
            except ValueError:
                raise ValueError(f"Invalid SZ value: {val}")
        elif key == "KM":
            try:
                komi = float(val)
            except ValueError:
                raise ValueError(f"Invalid KM value: {val}")
        elif key in ("B", "W"):
            color = key  # "B" or "W"
            gtp = _sgf_to_gtp(val, board_size)
            moves.append((color, gtp))
    return {"board_size": board_size, "komi": komi, "moves": moves}


def _sgf_to_gtp(sgf_coord: str, board_size: int) -> str:
    """Translate SGF `cd` style coords to KataGo GTP `D4` style.

    Empty string = pass.
    SGF uses 'a'..'s' for columns (no skip for I), with origin top-left.
    GTP uses 'A'..'T' for columns (skipping I), with origin bottom-left.
    """
    if not sgf_coord:
        return "pass"
    if len(sgf_coord) < 2:
        return "pass"
    col_idx = ord(sgf_coord[0]) - ord("a")
    row_idx = ord(sgf_coord[1]) - ord("a")
    if col_idx < 0 or row_idx < 0 or col_idx >= board_size or row_idx >= board_size:
        return "pass"
    # GTP columns skip I.
    gtp_cols = "ABCDEFGHJKLMNOPQRST"
    gtp_col = gtp_cols[col_idx]
    gtp_row = board_size - row_idx
    return f"{gtp_col}{gtp_row}"


def _gtp_to_rowcol(gtp: str, board_size: int) -> tuple[int, int] | None:
    if not gtp or gtp.lower() == "pass":
        return None
    gtp_cols = "ABCDEFGHJKLMNOPQRST"
    col_char = gtp[0].upper()
    if col_char not in gtp_cols:
        return None
    col = gtp_cols.index(col_char)
    try:
        row_from_bottom = int(gtp[1:])
    except ValueError:
        return None
    row = board_size - row_from_bottom
    if row < 0 or col < 0 or row >= board_size or col >= board_size:
        return None
    return (row, col)


def _shape_response(katago_resp: dict[str, Any], board_size: int) -> dict[str, Any]:
    """Convert one KataGo `turnNumber` response into the Flutter eval format."""
    root_info = katago_resp.get("rootInfo", {}) or {}
    move_infos = katago_resp.get("moveInfos", []) or []
    # KataGo reports winrate from the player-to-move's perspective. The
    # Flutter client wants black-perspective, so flip when it's white to move.
    raw_win = root_info.get("winrate", 0.5)
    score_lead = root_info.get("scoreLead", 0.0)
    next_player = (katago_resp.get("turnNumber", 0) % 2 == 0) and "B" or "W"
    black_win = raw_win if next_player == "B" else 1.0 - raw_win
    if next_player == "W":
        score_lead = -score_lead

    top_moves: list[list[int]] = []
    top_win: list[float] = []
    for mi in sorted(
        move_infos, key=lambda m: m.get("order", 99)
    )[:3]:
        rc = _gtp_to_rowcol(mi.get("move", ""), board_size)
        if rc is None:
            continue
        top_moves.append([rc[0], rc[1]])
        # moveInfos winrate is from KataGo's perspective too.
        wr = mi.get("winrate", 0.5)
        top_win.append(wr if next_player == "B" else 1.0 - wr)

    return {
        "blackWinRate": black_win,
        "scoreLead": score_lead,
        "topMoves": top_moves,
        "topMoveWinRates": top_win,
    }
