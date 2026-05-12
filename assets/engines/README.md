# Bundled KataGo Engine Assets

Place KataGo binaries here so the app ships with a zero-config AI engine.
At first launch the app extracts these files to the app's private support
directory and starts the engine automatically — no user setup needed.

## Required files

| Path | Description |
|------|-------------|
| `windows/katago.exe` | KataGo CPU binary for Windows (x64) |
| `macos/katago` | KataGo CPU binary for macOS (x64 or ARM64) |
| `linux/katago` | KataGo CPU binary for Linux (x64) |
| `android/katago` | KataGo CPU binary for Android (arm64-v8a) |
| `model.bin.gz` | Neural-network weights (shared across all platforms) |

**Only add the platform files you actually ship.** Missing assets are silently
skipped — the app falls back to the user-placed engines folder, then to the
built-in MCTS engine.

## How to get the files

1. Go to <https://github.com/lightvector/KataGo/releases/latest>
2. Download the **CPU** build for each target platform
3. Rename the binary to `katago` (or `katago.exe` on Windows)
4. Download a neural-network model:
   - **b4c32** (~7 MB) — fast, suitable for mobile / low-end devices
   - **b18c384** (~30 MB) — stronger play, good for desktop
5. Rename the model to `model.bin.gz`

## pubspec.yaml declarations

The four platform subdirectories and the shared model are already declared in
`pubspec.yaml` under `flutter.assets`. Flutter will bundle any non-empty
directory; empty directories (with only `.gitkeep`) are skipped at build time.

## iOS

iOS App Store policy prohibits executing bundled binaries. KataGo on iOS
requires compiling the engine as a static/dynamic framework and calling it via
`dart:ffi`. This is tracked as a future milestone; the app currently falls back
to the built-in MCTS engine on iOS.

## .gitignore

Large binary files should NOT be committed to version control. Add this to
your root `.gitignore`:

```
assets/engines/windows/katago.exe
assets/engines/macos/katago
assets/engines/linux/katago
assets/engines/android/katago
assets/engines/model.bin.gz
```
