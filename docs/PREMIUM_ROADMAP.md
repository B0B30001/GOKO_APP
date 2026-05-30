# GOKO Premium Roadmap — UI Redesign · KataGo Analysis · Coaches/Classroom

> Design doc for three large, mostly-independent tracks. Written to be reviewed
> **before** any implementation. Nothing here is built yet.
> Status legend: ✅ exists · 🟡 partial · ❌ greenfield.

---

## 0. Current-state audit (what's actually in the repo today)

| Area | State | Notes |
|---|---|---|
| Puzzle Garden / Learn Garden | 🟡 | Winding-path map already built on `lib/widgets/garden/` (pedestal painter, themed bg, world gates, ambient decorations, 3D player stone). ~70% of the Gemini-mockup look. |
| Garden art | 🟡 | Procedural `CustomPainter` backgrounds + optional PNG fallback. Mockups want richer isometric tiles + zen-garden scenery. |
| AI engine | 🟡 | `AIEngine` abstraction exists; only `MctsEngine` remains. `AIEngineFactory.current()` always returns MCTS. |
| KataGo | ❌ | `katago_ffi_engine.dart`, `katago_local_engine.dart`, `analysis_client.dart` were **deleted** in commit `847d21e` (premium rip-out). `assets/engines/README.md` + `server/` are now **stale orphans**. |
| Game analysis | 🟡→❌ | `analysis_screen.dart` is a **replay scrubber only** — no engine eval, no win-rate graph, no move tags. |
| Progress data | ✅ local-only | `ProgressService` (SharedPreferences): solved puzzles, XP, stars, streak, rating history, lesson bookmarks. **No backend, no accounts** beyond OGS. |
| Backend | ❌ | App is offline-first + OGS WebSocket. No Supabase/Firebase. Supabase MCP **is** wired in this workspace. |

**Implication:** UI is iteration; KataGo + Coaches are new builds. KataGo is *not* a rewire — the old engines are gone.

---

## Track A — UI Redesign (Puzzle + Learn → Gemini mockups)

**Goal:** elevate the existing garden maps to the fidelity of the Gemini mockups
(isometric pedestal tiles with green-check completion, cloud→pagoda→koi-pond
zen scenery, world-gate banners, premium CTAs). chess.com / Candy-Crush vibe.

**No new dependencies. No backend. Lowest risk, fastest visible win.**

### A.1 Files touched
- `lib/widgets/garden/pedestal_painter.dart` — richer isometric tile: top-face bevel, side-face gradient, drop shadow, inset for the status glyph. Add a `completed` variant (green + check) matching mockups.
- `lib/widgets/garden/themed_background.dart` — layered parallax scenery: cloud band (top) → terraced zen garden (pagoda, stone lantern, bonsai, statues) → koi pond (bottom). Keep procedural painter as web/low-end fallback; allow per-theme PNG scenery from `assets/backgrounds/`.
- `lib/widgets/garden/world_gate.dart` — banner restyle to match the carved-stone header in the mockups (category title + count, locked/unlocked states).
- `lib/widgets/garden/path_connector.dart` — stepping-stone dotted path with subtle elevation, matching the winding ribbon in the mockups.
- `lib/widgets/garden/ambient_decorations.dart` — drifting clouds + petals/koi; parallax tied to scroll offset (already partially wired).
- `lib/screens/puzzle_garden_screen.dart` / `learn_garden_screen.dart` — wire the upgraded primitives; the card CTAs are already done.

### A.2 New assets (optional, progressive enhancement)
- Per-theme background PNGs (5 themes) under `assets/backgrounds/garden/`. Falls back to painter when absent, so this can ship art incrementally.
- The 3 Gemini PNGs are **mockups/references**, not shippable assets (wrong aspect/contain UI chrome). Real scenery art = separate task (commission or generate tileable layers).

### A.3 Phases
1. Pedestal + path + world-gate restyle (painter-only, no art deps) — immediate.
2. Layered parallax scenery painter (clouds/pagoda/pond) — immediate.
3. Optional PNG scenery hook + 5 theme backgrounds — when art is ready.

### A.4 Tests
- Extend `test/widget/puzzle_garden_screen_test.dart`: no-overflow on phone/tablet, painter renders for each of the 5 themes, completed/locked/current tile states.

**Effort: small–medium. Ships in pieces.**

---

## Track B — KataGo Analysis (on-device ONNX + chess.com-style move review)

**Goal:** a Game Review screen with a win-rate/score graph and per-move tags
(✦Brilliant / Best / Great / Good / Inaccuracy / Mistake / Blunder), plus board
arrows for KataGo's top moves. Zero server cost via on-device ONNX (the Kaya
approach), corrected for Flutter.

### B.0 The Flutter correction to Gemini's plan
Gemini assumed JS/TS. GOKO is Dart. Real paths:

| Platform | Runtime | Package | Status |
|---|---|---|---|
| Android / iOS / Win / macOS / Linux | ONNX Runtime native via FFI | `onnxruntime` (or `flutter_onnxruntime`) | ✅ works today |
| Web (Vercel) | `onnxruntime-web` (WASM + WebGPU) | hand-written `dart:js_interop` bridge | ⚠️ Dart pkgs say "web soon"; bridge it ourselves |

→ **Build native-first** (works now), **web as a follow-up phase** behind a thin JS-interop shim. Same `.onnx` weights, same encoder, two execution backends.

### B.1 Models (`kaya-go/kaya`, MIT)
- Tensors: `bin_input [1,22,19,19] f32`, `global_input [1,19] f32` →
  `policy [1,2,362]`, `value [1,3]`, `ownership/scoring [1,1,19,19]`, `miscvalue` (score lead).
- ⚠️ The repo's published nets are **b28c512** (huge, ~100 MB+ fp32) — desktop/web-GPU only. For mobile we must convert a **small net** (b6c96 / b10c128, ~5–15 MB) ourselves via `kaya-go/katago-onnx`, and ship `.uint8.onnx`.
- Board size: ONNX shape is fixed 19×19. For 9×9/13×13 puzzles/games, **pad to 19×19** and rely on the on-board-mask plane (KataGo nets are size-agnostic given the mask).

### B.2 Architecture
```
lib/services/ai/
  ai_engine.dart                  (exists — extend with analysis API)
  analysis/
    katago_input_encoder.dart     ❌ board → 22 planes + 19 globals (KataGo NN input spec)
    katago_onnx_engine.dart       ❌ loads .onnx, runs forward pass, decodes outputs
    onnx_backend.dart             ❌ interface: run(inputs)->outputs
    onnx_backend_ffi.dart         ❌ native (onnxruntime pkg)
    onnx_backend_web.dart         ❌ web (js_interop -> onnxruntime-web)
    move_classifier.dart          ❌ win-rate delta -> {Brilliant..Blunder}
  analysis_service.dart           ❌ orchestrates per-ply eval, caches, ChangeNotifier
lib/models/
  move_eval.dart                  ❌ {winrate, scoreLead, topMoves, classification}
```

### B.3 The hard part: input encoding
`katago_input_encoder.dart` must reproduce KataGo's documented NN input
(22 binary spatial planes: on-board mask, own/opp/empty, ko-ban, liberties 1/2/3,
last-5-move history, ladder features…; 19 globals: komi scaled, rules flags…).
**Getting this wrong = garbage evals with no error.** Mitigation: golden-vector
tests — encode known positions and assert byte-equality against KataGo reference
vectors generated offline.

### B.4 Move classification (Go analog of chess.com "Expected Points")
For each played move, `delta = winrate(best policy/searched move) − winrate(played)`
from the mover's POV:
- **Best** played == top move · **Great/Excellent** ≤1% · **Good** ≤3%
- **Inaccuracy** 3–6% · **Mistake** 6–12% · **Blunder** >12% (or big score swing)
- **✦Brilliant** = near-best **and** a sacrifice/tenuki (gives up stones or plays away from a hot fight) **and** not already totally winning — detect via gap between shallow policy prior and deep value
- **Book/Joseki** = matches a joseki pattern in the opening N moves
Thresholds centralized + tunable. Raw single-net forward pass is enough for
classification; optional shallow MCTS later for stronger move suggestions.

### B.5 UI
- Rework `analysis_screen.dart`: add win-rate ribbon graph (tap a ply to jump),
  per-move colored tag chips in the move list, board overlay arrows for top-3
  KataGo moves + ownership heatmap toggle.
- "Analyze" entry point from history + end-of-game.
- Run analysis in `compute()` isolate (native) / web worker (web) to keep 60fps.

### B.6 Phases
1. `onnx_backend` interface + native FFI backend + load a small net → forward pass smoke test.
2. `katago_input_encoder` + golden-vector tests (correctness gate).
3. `move_classifier` + `move_eval` model + unit tests on synthetic evals.
4. `analysis_service` (per-ply, cached, isolate) wired into `analysis_screen`.
5. Game Review UI: win-rate graph + tags + board arrows/heatmap.
6. Web backend (js_interop → onnxruntime-web, WASM then WebGPU).

### B.7 Risks
- Model size on mobile (need our own small-net conversion).
- Input-encoding fidelity (golden tests mandatory).
- Web JS-interop maintenance + WASM asset hosting (~big files on Vercel/CDN).
- Battery/latency on mobile (cap visits, throttle, "analyze on demand").

**Effort: large. Native MVP reachable; web is a real extra phase.**

---

## Track C — Coaches / Classroom (Codeforces/Lichess-Class style)

**Goal:** a coach creates a **group**, assembles **contests/homework** from GOKO
tsumego, students join via code, solve, and the coach sees a **live dashboard**
of who solved what. This is the only track that needs a **backend + accounts**.

### C.1 Backend choice — **Supabase** (recommended)
Postgres + Auth + Row-Level-Security + Realtime + generous free tier, and the
**Supabase MCP is already wired** here (can create schema/migrations directly).
Alternatives: Firebase (NoSQL, also fine) or custom (more work). Default: Supabase.

### C.2 Data model (Postgres)
```
profiles        (id=auth.uid, display_name, role: student|coach)
groups          (id, name, owner=coach, invite_code, created_at)
group_members   (group_id, user_id, role, joined_at)             -- RLS: members read own group
contests        (id, group_id, title, opens_at, closes_at, scoring)
contest_puzzles (contest_id, puzzle_id, order, points)
submissions     (id, contest_id, puzzle_id, user_id, solved, stars, attempts, solved_at)
```
RLS: students see only their groups/submissions; coach (group owner) sees all
submissions in their group. Realtime channel on `submissions` → live leaderboard.

### C.3 App architecture
```
lib/services/classroom/
  auth_service.dart          ❌ Supabase auth (email/anon/OGS-link)
  classroom_repository.dart  ❌ groups/contests/submissions CRUD + realtime
lib/models/classroom/        ❌ Group, Contest, ContestPuzzle, Submission
lib/screens/classroom/
  classroom_home_screen.dart ❌ role-aware hub (student: my groups; coach: my groups)
  group_screen.dart          ❌ members + contests list, invite code
  contest_builder_screen.dart❌ coach picks tsumego set, sets window/points
  contest_play_screen.dart   ❌ student solves (reuses PuzzleScreen)
  coach_dashboard_screen.dart❌ live per-student progress grid + leaderboard
```
- Add `supabase_flutter` dependency.
- Bridge existing `ProgressService` solves → push `submissions` when in a contest.
- Reuse existing `PuzzleScreen` + `puzzles.json`/OGS pool for contest content.

### C.4 Phases
1. Supabase project + schema + RLS (via MCP) + `supabase_flutter` auth.
2. Groups: create/join by code, membership, role.
3. Contest builder (coach) + contest play (student, reuse PuzzleScreen).
4. Submissions write-path + realtime coach dashboard/leaderboard.
5. Polish: deadlines, points, CSV export, notifications.

### C.5 Risks
- New auth surface (privacy of minors → keep PII minimal; anon + display name).
- Online-only feature in an offline-first app (gate cleanly; degrade gracefully).
- Content licensing for contest puzzles (own tsumego + OGS-sourced only).

**Effort: large. Backend + 5 screens + realtime.**

---

## Cross-cutting

### Dependencies to add (by track)
- B: `onnxruntime` (native FFI) [+ hand-rolled web js_interop]; large model asset hosting.
- C: `supabase_flutter`.
- A: none.

### Testing
- A: widget/golden tests for garden primitives.
- B: **golden-vector encoder tests** (correctness gate) + classifier unit tests.
- C: repository tests against a Supabase test schema; RLS policy tests.

### Localization
Every new user-facing string → `app_en.arb` + 5 locales + `gen-l10n`
(the completeness test enforces this — see `test/localization_test.dart`).

---

## Recommended sequence

1. **Track A (UI)** — ship the premium look now; zero risk, immediate payoff, makes the app demo-ready while bigger tracks cook.
2. **Track B (KataGo, native MVP)** — highest "wow"; the analysis + Brilliant-move tags are the headline feature. Web phase after native proves out.
3. **Track C (Coaches)** — highest *new* surface area (backend + accounts); best tackled once A/B make the product compelling enough to pitch to schools/coaches.

Each track is independently shippable. A and B can even progress in parallel
(different files). C should wait until the backend decision is locked.

---

## Open decisions for you
1. **Sequencing** — accept A → B → C, or reorder?
2. **KataGo platform priority** — native-only first (recommended), or web from day one?
3. **Coaches backend** — Supabase (recommended) vs Firebase vs custom?
4. **Garden art** — commission/generate real scenery PNGs, or ship painter-only first?
