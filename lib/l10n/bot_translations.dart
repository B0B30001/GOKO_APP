import 'package:flutter/widgets.dart';

import '../gen/l10n/app_localizations.dart';
import '../models/bot_profile.dart';

/// Maps each `BotProfile.name` to its localized description and taunts.
///
/// Bot definitions live as `const` literals in [bots_screen.dart], so the
/// English text on `BotProfile.description` and the `taunts` map is baked
/// into the binary. We keep those as English fallbacks, but at render time
/// we look up the localized version here.
String botDescription(BuildContext context, BotProfile bot) {
  final l = AppLocalizations.of(context);
  switch (bot.name) {
    case 'Panda':
      return l.botDescPanda;
    case 'Pup':
      return l.botDescPup;
    case 'Bunny':
      return l.botDescBunny;
    case 'Koi':
      return l.botDescKoi;
    case 'Tanuki':
      return l.botDescTanuki;
    case 'Pebble':
      return l.botDescPebble;
    case 'Heron':
      return l.botDescHeron;
    case 'Owl':
      return l.botDescOwl;
    case 'Crane':
      return l.botDescCrane;
    case 'Mantis':
      return l.botDescMantis;
    case 'Badger':
      return l.botDescBadger;
    case 'Kitsune':
      return l.botDescKitsune;
    case 'Phoenix':
      return l.botDescPhoenix;
    case 'Hawk':
      return l.botDescHawk;
    case 'Tiger':
      return l.botDescTiger;
    case 'Otter':
      return l.botDescOtter;
    case 'Dragon':
      return l.botDescDragon;
    case 'Samurai':
      return l.botDescSamurai;
    case 'Tengu':
      return l.botDescTengu;
    case 'Monk':
      return l.botDescMonk;
    case 'Oracle':
      return l.botDescOracle;
    case 'Sensei':
      return l.botDescSensei;
    case 'KataGo':
      return l.botDescKataGo;
    default:
      return bot.description; // English fallback
  }
}

/// Localized taunt for a bot. Falls back to the generic default taunt if the
/// bot has no custom line for this event.
String botTaunt(BuildContext context, BotProfile bot, BotEvent event) {
  final l = AppLocalizations.of(context);
  // Panda is the only bot with custom taunts today; add others here as they
  // get unique voice lines.
  if (bot.name == 'Panda') {
    switch (event) {
      case BotEvent.greet:
        return l.tauntPandaGreet;
      case BotEvent.win:
        return l.tauntPandaWin;
      case BotEvent.lose:
        return l.tauntPandaLose;
      case BotEvent.resign:
        return l.tauntDefaultResign;
    }
  }
  switch (event) {
    case BotEvent.greet:
      return l.tauntDefaultGreet;
    case BotEvent.win:
      return l.tauntDefaultWin;
    case BotEvent.lose:
      return l.tauntDefaultLose;
    case BotEvent.resign:
      return l.tauntDefaultResign;
  }
}
