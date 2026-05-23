/// Generates minimal WAV sound-effect files for GOKO.
///
/// Run with: dart scripts/gen_sounds.dart
///
/// Output: assets/sounds/*.wav
///
/// Each sound is synthesized from simple sine-wave tones with ADSR-style
/// amplitude shaping so they feel like real UI feedback.
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// ---------------------------------------------------------------------------
// WAV helpers
// ---------------------------------------------------------------------------

const _sampleRate = 44100;
const _channels = 1; // mono
const _bitsPerSample = 16;

/// Builds a standard PCM WAV [ByteData] from [samples] (values in –1.0..1.0).
ByteData buildWav(List<double> samples) {
  final numSamples = samples.length;
  final dataSize = numSamples * (_bitsPerSample ~/ 8);
  final fileSize = 44 + dataSize;
  final buf = ByteData(fileSize);
  int o = 0;

  void writeStr(String s) {
    for (final c in s.codeUnits) {
      buf.setUint8(o++, c);
    }
  }

  void writeU16(int v) {
    buf.setUint16(o, v, Endian.little);
    o += 2;
  }

  void writeU32(int v) {
    buf.setUint32(o, v, Endian.little);
    o += 4;
  }

  // RIFF header
  writeStr('RIFF');
  writeU32(fileSize - 8);
  writeStr('WAVE');
  // fmt  chunk
  writeStr('fmt ');
  writeU32(16); // chunk size
  writeU16(1); // PCM
  writeU16(_channels);
  writeU32(_sampleRate);
  writeU32(_sampleRate * _channels * (_bitsPerSample ~/ 8)); // byte rate
  writeU16(_channels * (_bitsPerSample ~/ 8)); // block align
  writeU16(_bitsPerSample);
  // data chunk
  writeStr('data');
  writeU32(dataSize);
  for (final s in samples) {
    final v = (s.clamp(-1.0, 1.0) * 32767).round();
    buf.setInt16(o, v, Endian.little);
    o += 2;
  }
  return buf;
}

// ---------------------------------------------------------------------------
// Synthesis helpers
// ---------------------------------------------------------------------------

/// Generates [durationMs] ms of silence.
List<double> silence(int durationMs) {
  return List.filled((_sampleRate * durationMs / 1000).round(), 0.0);
}

/// Single sine-wave tone at [hz] for [durationMs] ms.
/// [attack] / [decay] / [sustain] / [release] are fractions of total duration.
List<double> tone(
  double hz,
  int durationMs, {
  double amplitude = 0.6,
  double attack = 0.01,
  double decay = 0.05,
  double sustain = 0.7,
  double release = 0.24,
}) {
  final n = (_sampleRate * durationMs / 1000).round();
  final samples = <double>[];
  for (int i = 0; i < n; i++) {
    final t = i / _sampleRate;
    final phase = 2 * pi * hz * t;
    final raw = sin(phase);

    // ADSR envelope
    final frac = i / n;
    double env;
    if (frac < attack) {
      env = frac / attack;
    } else if (frac < attack + decay) {
      env = 1.0 - (1.0 - sustain) * (frac - attack) / decay;
    } else if (frac < 1.0 - release) {
      env = sustain;
    } else {
      env = sustain * (1.0 - (frac - (1.0 - release)) / release);
    }

    samples.add(raw * env * amplitude);
  }
  return samples;
}

/// Mix [a] and [b] together (simple sum, clipped by buildWav).
List<double> mix(List<double> a, List<double> b) {
  final len = max(a.length, b.length);
  return List.generate(len, (i) {
    final va = i < a.length ? a[i] : 0.0;
    final vb = i < b.length ? b[i] : 0.0;
    return va + vb;
  });
}

/// Concatenate two sample lists.
List<double> concat(List<double> a, List<double> b) => [...a, ...b];

// ---------------------------------------------------------------------------
// Sound definitions
// ---------------------------------------------------------------------------

/// stone_place — short wooden click
/// Simulated by a brief 200 Hz thud with fast decay + overtones.
List<double> stonePlace() {
  final fundamental = tone(220, 60, amplitude: 0.5, attack: 0.005, decay: 0.04, sustain: 0.1, release: 0.85);
  final click = tone(800, 25, amplitude: 0.3, attack: 0.002, decay: 0.05, sustain: 0.05, release: 0.9);
  return mix(fundamental, click);
}

/// capture — heavier thump
List<double> capture() {
  final thump = tone(140, 120, amplitude: 0.6, attack: 0.005, decay: 0.06, sustain: 0.2, release: 0.72);
  final high  = tone(560, 60, amplitude: 0.25, attack: 0.002, decay: 0.05, sustain: 0.1, release: 0.84);
  return mix(thump, high);
}

/// correct — short ascending two-note ding
List<double> correct() {
  final note1 = tone(660, 120, amplitude: 0.5, attack: 0.01, decay: 0.05, sustain: 0.6, release: 0.34);
  final note2 = tone(880, 180, amplitude: 0.55, attack: 0.01, decay: 0.05, sustain: 0.6, release: 0.34);
  return concat(note1, concat(silence(20), note2));
}

/// wrong — descending buzz
List<double> wrong() {
  final note1 = tone(330, 130, amplitude: 0.55, attack: 0.01, decay: 0.05, sustain: 0.55, release: 0.39);
  final note2 = tone(220, 160, amplitude: 0.5, attack: 0.01, decay: 0.05, sustain: 0.5, release: 0.44);
  return concat(note1, concat(silence(15), note2));
}

/// complete — three rising notes (puzzle solved)
List<double> complete() {
  final n1 = tone(523, 130, amplitude: 0.5, attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.30);
  final n2 = tone(659, 130, amplitude: 0.52, attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.30);
  final n3 = tone(784, 220, amplitude: 0.55, attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.30);
  return concat(n1, concat(silence(20), concat(n2, concat(silence(20), n3))));
}

/// lesson_complete — uplifting four-note fanfare
List<double> lessonComplete() {
  final n1 = tone(523, 130, amplitude: 0.5, attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.30);
  final n2 = tone(659, 130, amplitude: 0.52, attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.30);
  final n3 = tone(784, 130, amplitude: 0.54, attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.30);
  final n4 = tone(1047, 300, amplitude: 0.56, attack: 0.01, decay: 0.04, sustain: 0.65, release: 0.30);
  return concat(n1, concat(silence(15), concat(n2, concat(silence(15), concat(n3, concat(silence(15), n4))))));
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  final outDir = Directory('assets/sounds');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final sounds = {
    'stone_place': stonePlace(),
    'capture': capture(),
    'correct': correct(),
    'wrong': wrong(),
    'complete': complete(),
    'lesson_complete': lessonComplete(),
  };

  for (final entry in sounds.entries) {
    final wav = buildWav(entry.value);
    final file = File('${outDir.path}/${entry.key}.wav');
    file.writeAsBytesSync(wav.buffer.asUint8List());
    print('✓ ${file.path}  (${file.lengthSync()} bytes)');
  }

  print('\nDone. Add to pubspec.yaml assets if not already listed.');
}
