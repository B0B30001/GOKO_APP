# GOKO analysis server

FastAPI wrapper around `katago analysis`. Provides one HTTPS endpoint
(`POST /v1/analyse`) consumed by the Flutter client
([`lib/services/ai/analysis_client.dart`](../lib/services/ai/analysis_client.dart)).

See the full deploy walkthrough in
[`C:\Users\User\.claude\plans\ok-so-when-loged-lively-reef.md`](../../.claude/plans/ok-so-when-loged-lively-reef.md)
(Phase G — free-tier Oracle Cloud path recommended).

## Quick start (Ubuntu / ARM Oracle Cloud Always Free)

```bash
# 1. KataGo (Eigen CPU build for ARM)
sudo apt update && sudo apt install -y g++ cmake libzip-dev libeigen3-dev git python3-pip
git clone https://github.com/lightvector/KataGo.git && cd KataGo/cpp
cmake . -DUSE_BACKEND=EIGEN -DCMAKE_BUILD_TYPE=Release
make -j4
sudo cp katago /usr/local/bin/

# 2. Network (20-block, ~20 MB, strong but CPU-friendly)
sudo mkdir -p /opt/katago
sudo wget https://media.katagotraining.org/g170/neuralnets/g170e-b20c256x2-s5303129600-d1228401921.bin.gz \
  -O /opt/katago/model.bin.gz

# 3. Default analysis config from upstream
sudo wget https://raw.githubusercontent.com/lightvector/KataGo/master/cpp/configs/analysis_example.cfg \
  -O /opt/katago/analysis_example.cfg

# 4. Server
cd /path/to/Zaibal/server
pip3 install --user -r requirements.txt
export ZAIBAL_ANALYSIS_TOKEN=$(openssl rand -hex 32)
echo "Save this token — you'll set it as --dart-define for the app: $ZAIBAL_ANALYSIS_TOKEN"
uvicorn main:app --host 0.0.0.0 --port 8080 --workers 1
```

## Building the Flutter client against this server

```bash
flutter run -d chrome \
  --dart-define=ZAIBAL_ANALYSIS_URL=https://goko-api.duckdns.org \
  --dart-define=ZAIBAL_ANALYSIS_TOKEN=<token from above>
```

For a free public URL + TLS in front of port 8080, put Caddy on the same box:

```caddy
goko-api.duckdns.org {
  reverse_proxy localhost:8080
}
```

## Env vars

| Var | Default | Purpose |
|---|---|---|
| `KATAGO_BIN` | `/usr/local/bin/katago` | Path to KataGo binary |
| `KATAGO_MODEL` | `/opt/katago/model.bin.gz` | Neural-net file |
| `KATAGO_CONFIG` | `/opt/katago/analysis_example.cfg` | KataGo config |
| `ZAIBAL_ANALYSIS_TOKEN` | (empty) | Required bearer token. If empty, **any** caller is allowed — only do that on localhost. |

## Endpoint

```
POST /v1/analyse
Authorization: Bearer <token>
Content-Type: application/json

{ "sgf": "(;FF[4]GM[1]SZ[19]KM[7.5];B[pd];W[dp]...)", "maxVisits": 400 }
```

Returns `{ "evals": [{ blackWinRate, scoreLead, topMoves, topMoveWinRates }, ...] }`
— one entry per ply, indexed 0..N where 0 = empty board.
