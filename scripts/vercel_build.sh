#!/bin/bash
set -e

echo "==> Fetching Flutter download URL for latest stable..."

# Fetch the releases JSON and extract the latest stable download URL
RELEASES_JSON=$(curl -s "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json")
STABLE_HASH=$(echo "$RELEASES_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['current_release']['stable'])")
BASE_URL=$(echo "$RELEASES_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['base_url'])")
ARCHIVE=$(echo "$RELEASES_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); [print(r['archive']) for r in d['releases'] if r['hash']=='$STABLE_HASH']" | head -1)
FLUTTER_URL="$BASE_URL/$ARCHIVE"

echo "==> Downloading Flutter from: $FLUTTER_URL"
wget -q "$FLUTTER_URL" -O /tmp/flutter.tar.xz

echo "==> Extracting Flutter..."
tar xf /tmp/flutter.tar.xz -C /opt/

export PATH="$PATH:/opt/flutter/bin"

echo "==> Configuring Flutter..."
flutter config --no-analytics
flutter config --enable-web

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web..."
flutter build web --release

echo "==> Build complete! Output in build/web"
