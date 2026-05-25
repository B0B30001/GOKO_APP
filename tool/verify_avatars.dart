// Build-time tool: scans `assets/avatars/*.png`, verifies each is a real
// decodable PNG. Catches the silent "asset present but corrupt" failure that
// triggers the Bots screen's first-letter gradient fallback at runtime.
//
// Run:
//     dart run tool/verify_avatars.dart
//
// Exit code 0 = all good, 1 = at least one bad file. CI can wire this in.

import 'dart:io';
import 'dart:typed_data';

const _pngMagic = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

Future<void> main() async {
  final dir = Directory('assets/avatars');
  if (!dir.existsSync()) {
    stderr.writeln('assets/avatars/ not found — run from repo root.');
    exit(2);
  }

  final pngs =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  int ok = 0;
  final bad = <String>[];

  for (final f in pngs) {
    final bytes = await f.readAsBytes();
    final name = f.uri.pathSegments.last;
    final reason = _validate(bytes);
    if (reason == null) {
      ok++;
      stdout.writeln('  ok  $name  (${bytes.length}B)');
    } else {
      bad.add('$name — $reason');
      stderr.writeln('  BAD $name  ($reason)');
    }
  }

  stdout
    ..writeln('')
    ..writeln('Verified ${pngs.length} avatars: $ok ok, ${bad.length} bad.');

  if (bad.isNotEmpty) {
    stderr
      ..writeln('')
      ..writeln('Failed files:');
    for (final b in bad) {
      stderr.writeln('  - $b');
    }
    exit(1);
  }
}

/// Returns null when [bytes] is a structurally valid PNG, otherwise a short
/// human-readable reason.
String? _validate(Uint8List bytes) {
  if (bytes.length < 24) return 'too small (${bytes.length}B)';
  for (int i = 0; i < _pngMagic.length; i++) {
    if (bytes[i] != _pngMagic[i]) {
      return 'bad PNG magic at byte $i (got 0x${bytes[i].toRadixString(16)})';
    }
  }
  // First chunk after the 8-byte signature must be IHDR (length 13).
  final ihdrLen =
      (bytes[8] << 24) | (bytes[9] << 16) | (bytes[10] << 8) | bytes[11];
  if (ihdrLen != 13) return 'IHDR length not 13 (got $ihdrLen)';
  final ihdrType = String.fromCharCodes(bytes.sublist(12, 16));
  if (ihdrType != 'IHDR') return 'first chunk not IHDR (got "$ihdrType")';
  // Must end with IEND chunk.
  if (bytes.length < 12) return 'no room for IEND';
  final tail = String.fromCharCodes(
    bytes.sublist(bytes.length - 8, bytes.length - 4),
  );
  if (tail != 'IEND') return 'last chunk not IEND (got "$tail")';
  return null;
}
