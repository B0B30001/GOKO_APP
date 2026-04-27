#!/bin/bash
set -e

FLUTTER_HOME="$HOME/flutter"
export PATH="$PATH:$FLUTTER_HOME/bin"

echo "==> Fetching Flutter stable download URL..."

# Get the full download URL - store curl output first, then parse with python3 -c
FLUTTER_JSON=$(curl -s "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json")
FLUTTER_URL=$(echo "$FLUTTER_JSON" | python3 -c "
import json, sys
d = json.load(sys.stdin)
stable_hash = d['current_release']['stable']
base_url = d['base_url']
for r in d['releases']:
    if r['hash'] == stable_hash:
        print(base_url + '/' + r['archive'])
        break
")

echo "==> Downloading Flutter from: $FLUTTER_URL"
curl -L --progress-bar "$FLUTTER_URL" -o /tmp/flutter.tar.xz

echo "==> Extracting Flutter to $HOME..."
tar xf /tmp/flutter.tar.xz -C "$HOME"
rm /tmp/flutter.tar.xz

echo "==> Fixing git safe directory (Vercel runs as root)..."
git config --global --add safe.directory "$FLUTTER_HOME"

echo "==> Configuring Flutter..."
flutter config --no-analytics
flutter config --enable-web

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web..."
flutter build web --release

echo "==> Build complete! Output in build/web"
