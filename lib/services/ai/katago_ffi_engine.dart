// Conditional re-export: native (`dart:ffi`) on Android/iOS/desktop, a
// no-op stub on web. Importers should keep using `katago_ffi_engine.dart`
// and never touch the `_io`/`_web` files directly.
export 'katago_ffi_engine_web.dart'
    if (dart.library.io) 'katago_ffi_engine_io.dart';
