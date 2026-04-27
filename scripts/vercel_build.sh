#!/bin/bash
set -e

FLUTTER_HOME="$HOME/flutter"
export PATH="$PATH:$FLUTTER_HOME/bin"

echo "==> Fetching Flutter stable download URL..."

# Get the full download URL in one Python call
FLUTTER_URL=$(curl -s "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json" | python3 - <<'EOF'
import json, sys
d = json.load(sys.stdin)
stable_hash = d["current_release"]["stable"]
base_url = d["base_url"]
for r in d["releases"]:
    if r["hash"] == stable_hash:
        print(base_url + "/" + r["archive"])
        break
EOF
)

echo "==> Downloading Flutter from: $FLUTTER_URL"
curl -L --progress-bar "$FLUTTER_URL" -o /tmp/flutter.tar.xz

echo "==> Extracting Flutter to $HOME..."
tar xf /tmp/flutter.tar.xz -C "$HOME"
rm /tmp/flutter.tar.xz

echo "==> Configuring Flutter..."
flutter config --no-analytics
flutter config --enable-web

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web..."
flutter build web --release

echo "==> Build complete! Output in build/web"
