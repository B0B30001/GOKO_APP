import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/l10n/puzzle_translations.dart';
import 'package:zaibal/models/puzzle.dart';

void main() {
  group('ARB completeness', () {
    // Loads the raw ARB JSON for each locale once and asserts every key in
    // English (ignoring @-prefixed metadata) has a non-empty value in all 5
    // other locales. This is the only way to catch a missing translation
    // since `flutter gen-l10n` will silently fall back to English at runtime.
    final enRaw = File('lib/l10n/app_en.arb').readAsStringSync();
    final en = jsonDecode(enRaw) as Map<String, dynamic>;
    final keys = en.keys.where((k) => !k.startsWith('@')).toList();

    for (final locale in ['ru', 'de', 'zh', 'ja', 'ko']) {
      test('$locale has a non-empty value for every English key', () {
        final raw = File('lib/l10n/app_$locale.arb').readAsStringSync();
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final missing = <String>[];
        final empty = <String>[];
        for (final k in keys) {
          if (!map.containsKey(k)) {
            missing.add(k);
            continue;
          }
          final v = map[k];
          if (v is! String || v.trim().isEmpty) {
            empty.add(k);
          }
        }
        expect(
          missing,
          isEmpty,
          reason: 'missing keys in $locale: ${missing.join(", ")}',
        );
        expect(
          empty,
          isEmpty,
          reason: 'empty values in $locale: ${empty.join(", ")}',
        );
      });
    }

    test('English ARB has no orphaned @-metadata for absent keys', () {
      final atKeys = en.keys
          .where((k) => k.startsWith('@') && !k.startsWith('@@'))
          .toList();
      final orphans = <String>[];
      for (final at in atKeys) {
        final stripped = at.substring(1);
        if (!en.containsKey(stripped)) orphans.add(at);
      }
      expect(orphans, isEmpty, reason: 'orphan @-keys: ${orphans.join(", ")}');
    });
  });

  group('AppLocalizations', () {
    test('supports en/ru/zh/ja/ko locales', () async {
      for (final code in ['en', 'ru', 'zh', 'ja', 'ko']) {
        final l = await AppLocalizations.delegate.load(Locale(code));
        // App name renders in every locale (e.g. "GOKO" or "ГОКО") — must be
        // non-empty for the locale's lookup to be considered wired up.
        expect(l.appName, isNotEmpty, reason: 'appName missing for $code');
        expect(l.play, isNotEmpty, reason: 'play missing for $code');
        expect(l.settings, isNotEmpty, reason: 'settings missing for $code');
      }
    });

    test('Russian translations differ from English where expected', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      // A spot check on a few representative keys — Russian must not silently
      // fall back to English strings.
      expect(ru.settings, isNot(equals(en.settings)));
      expect(ru.darkMode, isNot(equals(en.darkMode)));
      expect(ru.playVsBotTitle, isNot(equals(en.playVsBotTitle)));
    });

    test(
      'plural-like placeholder methods exist and return non-empty',
      () async {
        final ru = await AppLocalizations.delegate.load(const Locale('ru'));
        expect(ru.stepXofY(3, 5), contains('3'));
        expect(ru.stepXofY(3, 5), contains('5'));
        expect(ru.swapsLeft(2), contains('2'));
        expect(ru.solvedCount(1, 5), contains('1'));
        expect(ru.solvedCount(1, 5), contains('5'));
      },
    );
  });

  group('PuzzleI18n', () {
    test('every Dart-defined puzzle has at least an English fallback', () {
      // The contract is: a missing translation is OK (falls back to puzzle
      // .title / .description / .hint), but the underlying English fields
      // must never be empty so the fallback is meaningful.
      for (final p in PuzzleData.allPuzzles) {
        expect(p.title, isNotEmpty, reason: 'title empty for ${p.id}');
        expect(
          p.description,
          isNotEmpty,
          reason: 'description empty for ${p.id}',
        );
      }
    });

    test('Russian translations exist for known puzzle ids', () {
      // Spot check — translations should be present for the canonical 27
      // puzzles, returning strings that don't look like English.
      const ids = [
        'capture_1',
        'liberty_1',
        'life_death_1',
        'ko_1',
        'tesuji_1',
      ];
      for (final id in ids) {
        final ruTitle = PuzzleI18n.translate(
          puzzleId: id,
          field: 'title',
          languageCode: 'ru',
        );
        expect(ruTitle, isNotNull, reason: 'missing ru.title for $id');
        expect(ruTitle, isNotEmpty);
      }
    });

    test('unknown locale falls back to null', () {
      final missing = PuzzleI18n.translate(
        puzzleId: 'capture_1',
        field: 'title',
        languageCode: 'xx',
      );
      expect(missing, isNull);
    });
  });
}
