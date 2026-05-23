/// Tunable parameters that drive how strong (and how human-feeling) a bot
/// plays. Lives on each `BotProfile`; the cloud engine reads it when it
/// builds the analysis request for the bot's next move.
///
/// Strength axes:
/// - [maxVisits] : raw KataGo search budget. Higher = stronger reading.
/// - [policyTemperature] : softens the policy distribution. >1 makes weaker
///   moves more probable (kept for parity with KataGo's analysis API even
///   though we don't sample from the distribution directly; reserved for
///   server-side hinting).
/// - [sampleTopN] : pick uniformly among the top-N engine candidates.
///   `1` = always best, `8` = beginner who plays sub-optimal moves often.
/// - [blunderRate] : 0..1, probability the bot plays a random legal move
///   instead of consulting the engine. Mimics beginner shape-blindness
///   without paying for a search.
///
/// Construct via the named bot presets below or hand-tune per bot.
class BotEngineConfig {
  final int maxVisits;
  final double policyTemperature;
  final int sampleTopN;
  final double blunderRate;

  const BotEngineConfig({
    required this.maxVisits,
    this.policyTemperature = 1.0,
    this.sampleTopN = 1,
    this.blunderRate = 0.0,
  });

  /// Hand-tuned tier presets keyed roughly to Elo bands. Use these as
  /// starting points; per-bot overrides are fine when you want flavour.
  static const beginner = BotEngineConfig(
    maxVisits: 4,
    policyTemperature: 2.0,
    sampleTopN: 8,
    blunderRate: 0.30,
  );

  static const earlyKyu = BotEngineConfig(
    maxVisits: 16,
    policyTemperature: 1.5,
    sampleTopN: 5,
    blunderRate: 0.10,
  );

  static const intermediate = BotEngineConfig(
    maxVisits: 64,
    policyTemperature: 1.2,
    sampleTopN: 3,
    blunderRate: 0.05,
  );

  static const advanced = BotEngineConfig(
    maxVisits: 128,
    policyTemperature: 1.1,
    sampleTopN: 2,
    blunderRate: 0.0,
  );

  static const dan = BotEngineConfig(
    maxVisits: 400,
    policyTemperature: 1.0,
    sampleTopN: 1,
    blunderRate: 0.0,
  );

  static const master = BotEngineConfig(
    maxVisits: 800,
    policyTemperature: 1.0,
    sampleTopN: 1,
    blunderRate: 0.0,
  );

  static const superhuman = BotEngineConfig(
    maxVisits: 1600,
    policyTemperature: 1.0,
    sampleTopN: 1,
    blunderRate: 0.0,
  );
}
