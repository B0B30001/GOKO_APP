// One-shot recovery for the 5 bot avatar PNGs whose first 17 bytes are the
// literal ASCII text  \x89PNG\r\n\x1a\n  (an earlier session wrote the
// escape-sequence string instead of the actual 8 magic bytes). The rest of
// each file is intact PNG data. Detect the broken header, prepend the real
// magic, save in place.
//
//     dart run tool/recover_avatars.dart
//
// Safe to re-run: files already starting with the correct magic are skipped.

import 'dart:io';
import 'dart:typed_data';

const _realMagic = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
const _brokenPrefix = r'\x89PNG\r\n\x1a\n'; // 17 ASCII chars
final _brokenBytes = Uint8List.fromList(_brokenPrefix.codeUnits);

Future<void> main() async {
  final dir = Directory('assets/avatars');
  final pngs =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  int fixed = 0;
  int skipped = 0;
  int alreadyOk = 0;

  for (final f in pngs) {
    final bytes = await f.readAsBytes();
    final name = f.uri.pathSegments.last;
    if (_startsWith(bytes, _realMagic)) {
      alreadyOk++;
      continue;
    }
    if (!_startsWith(bytes, _brokenBytes)) {
      skipped++;
      stderr.writeln('  ?   $name  unknown corruption pattern, leaving alone');
      continue;
    }
    final repaired = Uint8List(bytes.length - _brokenBytes.length + 8)
      ..setRange(0, 8, _realMagic)
      ..setRange(
        8,
        bytes.length - _brokenBytes.length + 8,
        bytes.sublist(_brokenBytes.length),
      );
    await f.writeAsBytes(repaired, flush: true);
    fixed++;
    stdout.writeln('  fix $name  (${bytes.length}B -> ${repaired.length}B)');
  }

  stdout
    ..writeln('')
    ..writeln('Done. fixed=$fixed  alreadyOk=$alreadyOk  skipped=$skipped');
}

bool _startsWith(List<int> bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (int i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}
