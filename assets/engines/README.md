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
`dart:ffi`. See the **Native FFI build** section below for the path.

## Native FFI build (Android + iOS) — the proper mobile path

The Dart side of this is already wired:
[`lib/services/ai/katago_ffi_engine.dart`](../../lib/services/ai/katago_ffi_engine.dart).
It looks for a native shared library at runtime; when it can't find one, the
factory falls through to MCTS without crashing. To actually ship it:

### 1. Where to download neural-network weights

Pick one based on target device:

| File | Size | Strength | Notes |
|------|------|----------|-------|
| `kata1-b6c96-s175395328-d26788732.bin.gz` | ~30 MB | ~3 kyu | **Mobile-friendly.** ~1-2 s per move on a 2023 phone. |
| `kata1-b18c384nbt-s9133861888-d4204142634.bin.gz` | ~250 MB | Pro | Desktop only — too big for mobile bundles. |

Browse all networks: <https://katagotraining.org/networks/>
KataGo releases: <https://github.com/lightvector/KataGo/releases>

### 2. Where to download / clone KataGo source

```bash
git clone --depth 1 https://github.com/lightvector/KataGo.git
cd KataGo/cpp
```

The `cpp/` directory is the C++ engine.

### 3. Build for Android (arm64-v8a)

Requirements: **Android NDK r25+**, **CMake ≥ 3.18**, **Eigen** (header-only).

```bash
export ANDROID_NDK=$HOME/Android/Sdk/ndk/25.2.9519653
cmake -B build-android \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-24 \
  -DUSE_BACKEND=EIGEN \
  -DBUILD_DISTRIBUTED=0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON
cmake --build build-android -j8
# Output: build-android/libkatago.so
```

Place the result here:
```
android/app/src/main/jniLibs/arm64-v8a/libkatago.so
```

You'll also need to expose a C entrypoint `katago_predict()` that the Dart
FFI bindings can call — see the typedef in `katago_ffi_engine.dart`. The
KataGo source doesn't ship this shim out of the box; you write a small
wrapper in `cpp/main_ffi.cpp` that wraps `Search` / `BoardHistory` and
exposes the symbol with `extern "C"`.

### 4. Build for iOS

Requirements: **Xcode 15+**, **macOS host**.

```bash
cmake -B build-ios \
  -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake \
  -DPLATFORM=OS64 \
  -DUSE_BACKEND=EIGEN \
  -DBUILD_DISTRIBUTED=0 \
  -DBUILD_SHARED_LIBS=ON
cmake --build build-ios --config Release
# Output: build-ios/katago.dylib (or .framework)
```

Drop the resulting `.framework` into `ios/Runner/Frameworks/`, then add it as
an "Embed & Sign" framework in Xcode under the Runner target's General tab.

(`ios.toolchain.cmake` is the standard iOS CMake toolchain file from
<https://github.com/leetal/ios-cmake>.)

### 5. Bundling the model file

Drop the chosen `*.bin.gz` weight file at `assets/engines/katago/model.bin.gz`
and declare it in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/engines/katago/
```

The FFI engine extracts the model from `rootBundle` to the app documents
directory on first launch and passes its path to the C library.

### 6. Enable it in Settings

In the app, go to **Settings → AI / KataGo** and switch the mode to
**Native**. The factory in `ai_engine_factory.dart` will then route AI
move requests through `KataGoFfiEngine` instead of MCTS.

### Realistic mobile constraints

- **App size:** the small (~30 MB) model + ~10 MB arm64 binary = ~40 MB
  added to your APK / IPA. The 250 MB model is impractical for a bundled
  shipment — use lazy-download from a CDN if you need pro strength.
- **Move latency:** even the small model is ~1-2 s per move on a flagship
  phone, ~3-5 s on midrange. Adjust `playoutDoublingAdvantage` and
  `maxVisits` in the KataGo config to trade strength for speed.
- **iOS review:** Apple reviews large embedded binaries carefully. A
  bundled neural-net model is fine, but a bundled native binary needs to
  be a real framework (signed) — not a raw executable.
- **Battery:** running KataGo neural-net inference for 5+ seconds per move
  is noticeable on battery. Warn users before games on mobile.

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
