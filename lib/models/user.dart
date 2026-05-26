/// Represents the locally signed-in player.
///
/// Fields are intentionally optional where a fresh first-launch user has no
/// data yet (e.g., no rank until they sign in to OGS).
///
/// GOKO is fully free in the current build — there is no subscription tier,
/// no premium gates, no IAP. The User model deliberately has no `isPremium`
/// flag any more; the [SubscriptionService] stub reports all features as
/// available unconditionally.
class User {
  final String id;
  String displayName;
  String? avatarPath;

  /// Go rank string, e.g. "12k", "1d", "3p". Sourced from OGS when available.
  String? rank;

  int gamesPlayed;
  int wins;
  int losses;
  int puzzleRating;

  /// Cosmetic flair identifiers (badges, border styles). Award flow is local.
  List<String> badges;

  User({
    required this.id,
    required this.displayName,
    this.avatarPath,
    this.rank,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.puzzleRating = 1200,
    List<String>? badges,
  }) : badges = badges ?? <String>[];

  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'avatarPath': avatarPath,
    'rank': rank,
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'losses': losses,
    'puzzleRating': puzzleRating,
    'badges': badges,
  };

  static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    avatarPath: json['avatarPath'] as String?,
    rank: json['rank'] as String?,
    gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
    wins: (json['wins'] as num?)?.toInt() ?? 0,
    losses: (json['losses'] as num?)?.toInt() ?? 0,
    puzzleRating: (json['puzzleRating'] as num?)?.toInt() ?? 1200,
    badges: (json['badges'] as List?)?.cast<String>() ?? const <String>[],
  );
}
