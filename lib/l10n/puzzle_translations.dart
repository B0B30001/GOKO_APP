import 'package:flutter/widgets.dart';
import '../models/puzzle.dart';

/// Side-table of localized strings for puzzles defined in [PuzzleData].
///
/// Keeping the Dart puzzle definitions canonical (shapes, solutions, IDs) and
/// translating user-facing strings here avoids editing the 1200-line
/// `puzzle.dart` with foreign-language literals.
///
/// Lookup chain: `_translations[locale][puzzleId][field]`. Missing entries fall
/// back to the English value already in [Puzzle].
class PuzzleI18n {
  /// Outer key = BCP-47 language code; inner key = puzzle id; values =
  /// {title, description, hint}.
  static const Map<String, Map<String, Map<String, String>>> _translations = {
    'ru': {
      'capture_1': {
        'title': 'Простой захват',
        'description': 'Захватите белый камень, заняв его последнее дамэ',
        'hint': 'Найдите белый камень, у которого осталось только одно дамэ',
      },
      'capture_2': {
        'title': 'Захват двух камней',
        'description': 'Захватите два белых камня подряд',
        'hint': 'Найдите общее последнее дамэ двух белых камней',
      },
      'capture_3': {
        'title': 'Захват в углу',
        'description': 'Используйте угол, чтобы поймать белые камни',
        'hint': 'Угол ограничивает дамэ белого',
      },
      'capture_4': {
        'title': 'Захват сетью (гэта)',
        'description': 'Белый камень не может убежать — поймайте его сетью',
        'hint': 'Сыграйте над белым камнем, чтобы перекрыть путь побега',
      },
      'capture_5': {
        'title': 'Двойное атари',
        'description': 'Один ход ставит два отдельных белых камня в атари',
        'hint': 'Найдите точку, атакующую сразу оба белых камня',
      },
      'capture_6': {
        'title': 'Захват на краю',
        'description': 'Захватите одинокий белый камень на краю',
        'hint': 'Край убирает два дамэ — найдите последнее',
      },
      'capture_7': {
        'title': 'Захват трёх камней',
        'description': 'У группы из трёх белых только одно общее дамэ',
        'hint': 'Белая группа почти окружена — найдите последнее дамэ',
      },
      'capture_8': {
        'title': 'Захват в два хода',
        'description': 'Сведите в атари, а затем захватите за два хода',
        'hint': 'Сначала сведите белого в атари, потом захватите',
      },
      'liberty_1': {
        'title': 'Подсчёт дамэ — одиночный камень',
        'description': 'У этого чёрного камня 4 дамэ',
        'hint': 'Посчитайте сверху, снизу, слева и справа от камня',
      },
      'liberty_2': {
        'title': 'Соединённые камни делят дамэ',
        'description': 'У этой чёрной группы всего 6 дамэ',
        'hint': 'Соединённые камни — одна группа с общими дамэ',
      },
      'liberty_3': {
        'title': 'Уменьшайте дамэ для захвата',
        'description': 'У белого 2 дамэ. Сократите до 1 — атари!',
        'hint': 'Сыграйте рядом с белым камнем, чтобы уменьшить его дамэ',
      },
      'liberty_4': {
        'title': 'Побег из атари',
        'description': 'Ваш камень в атари — найдите путь к спасению',
        'hint': 'У вашего камня одно дамэ — продлите его в безопасное место',
      },
      'liberty_5': {
        'title': 'Избегайте самоатари',
        'description': 'Не ставьте свои камни в атари сами',
        'hint': 'Сосчитайте дамэ после вашего хода — не оставляйте только одно',
      },
      'liberty_6': {
        'title': 'Спасите свои камни',
        'description': 'Две группы в атари — можно спасти только одну',
        'hint': 'Обе спасти нельзя — выберите более важный камень',
      },
      'life_death_1': {
        'title': 'Сделайте два глаза',
        'description':
            'Чёрные окружены — разделите внутреннее пространство, чтобы создать два глаза',
        'hint': 'Сыграйте в середину, чтобы создать два отдельных глаза',
      },
      'life_death_2': {
        'title': 'Убейте белую группу',
        'description':
            'Сыграйте на жизненной точке, чтобы помешать белому сделать два глаза',
        'hint':
            'Сыграйте на центральную жизненную точку, чтобы не дать белому сделать два глаза',
      },
      'life_death_3': {
        'title': 'Жизнь в углу',
        'description':
            'Сделайте два глаза в углу, чтобы оставить чёрную группу живой',
        'hint': 'Соедините камни вдоль края, чтобы закрыть два глаза в углу',
      },
      'life_death_4': {
        'title': 'Накадэ — убить одним ходом',
        'description':
            'Заполните жизненную внутреннюю точку, чтобы помешать двум глазам',
        'hint':
            'Сыграйте внутри белой группы, чтобы не дать ей сделать два глаза',
      },
      'life_death_5': {
        'title': 'Используйте ложный глаз',
        'description': 'У белого ложный глаз — докажите, что группа не выживет',
        'hint': 'Изучите белую группу — настоящий ли глаз на (3,2) или ложный?',
      },
      'ko_1': {
        'title': 'Распознавание ко',
        'description': 'Определите и захватите в ситуации ко',
        'hint': 'Это повторяющийся узор, где можно захватывать туда-обратно',
      },
      'ko_2': {
        'title': 'Понимание правила ко',
        'description': 'Почему нельзя сразу же отбирать в ко',
        'hint':
            'После захвата в ко нужно сыграть в другом месте, прежде чем отбирать',
      },
      'ko_3': {
        'title': 'Захват в ко',
        'description': 'Чёрные захватывают белый камень в позиции ко',
        'hint': 'Белый в атари — захватите его, чтобы войти в ко',
      },
      'ko_4': {
        'title': 'Угрозы ко',
        'description': 'Поймите, как работают угрозы ко в борьбе за ко',
        'hint': 'Сыграйте угрозу, на которую противник обязан ответить',
      },
      'tesuji_1': {
        'title': 'Соедините свои камни',
        'description':
            'Сделайте ход, соединяющий две изолированные чёрные группы',
        'hint': 'Сыграйте ход, объединяющий ваши камни в одну группу',
      },
      'tesuji_2': {
        'title': 'Бамбуковый сустав',
        'description': 'Сформируйте бамбуковый сустав — нерушимое соединение',
        'hint': 'Найдите точку, образующую форму 2×2 с зазорами',
      },
      'tesuji_3': {
        'title': 'Тигриная пасть',
        'description': 'Используйте форму тигриной пасти для защиты от захвата',
        'hint': 'Сыграйте так, чтобы создать форму с пустой точкой посередине',
      },
      'tesuji_4': {
        'title': 'Лестница (сичо)',
        'description': 'Научитесь распознавать узор лестницы',
        'hint': 'Поставьте белого в атари с правильной стороны',
      },
    },
  };

  /// Look up the localized [field] (`title` / `description` / `hint`) for
  /// [puzzleId] in [languageCode]. Returns null if no translation exists; the
  /// caller should fall back to the English value on [Puzzle].
  static String? translate({
    required String puzzleId,
    required String field,
    required String languageCode,
  }) {
    return _translations[languageCode]?[puzzleId]?[field];
  }
}

/// Convenience accessors so screens can write `puzzle.localizedTitle(context)`
/// instead of threading locale + field name everywhere.
extension PuzzleLocalized on Puzzle {
  String localizedTitle(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return PuzzleI18n.translate(
          puzzleId: id,
          field: 'title',
          languageCode: code,
        ) ??
        title;
  }

  String localizedDescription(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return PuzzleI18n.translate(
          puzzleId: id,
          field: 'description',
          languageCode: code,
        ) ??
        description;
  }

  String localizedHint(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return PuzzleI18n.translate(
          puzzleId: id,
          field: 'hint',
          languageCode: code,
        ) ??
        hint;
  }
}
