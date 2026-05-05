/// Mapping helpers between OGS Glicko-2 numeric ratings and human-readable
/// kyu/dan ranks. OGS uses the Glicko-2 family with a base where rating 1400
/// ≈ 6k, scaled so that ~100 rating points equals one rank step.
///
/// The canonical formula on OGS (per their public docs / Sensei's Library):
///
///   rank_index = floor((rating - 525) / 100)        [0 = 30k]
///   for rank_index 0..29 → "(30 - rank_index)k"
///   for rank_index 30..  → "(rank_index - 29)d"
///
/// This is approximate — OGS itself displays a rank deviation band — but is
/// sufficient for player-card display where we just want a glanceable label.
class OgsRank {
  /// Format a numeric rating as a human rank string. Returns `'?'` for
  /// non-positive or NaN inputs.
  static String fromRating(num rating) {
    if (rating <= 0 || rating.isNaN || rating.isInfinite) return '?';
    final idx = ((rating - 525) / 100).floor();
    if (idx < 0) return '30k';
    if (idx <= 29) {
      final kyu = 30 - idx;
      return '${kyu}k';
    }
    final dan = idx - 29;
    if (dan > 9) return '9d';
    return '${dan}d';
  }

  /// Best-effort label from the various fields OGS might return:
  /// prefer the explicit `ranking`/`rank` string when it looks rank-shaped,
  /// otherwise derive from the numeric rating.
  static String? bestLabel({String? rankString, num? rating}) {
    if (rankString != null && rankString.isNotEmpty) {
      final lower = rankString.toLowerCase();
      // OGS sometimes returns just an integer like "30" — treat numeric-only
      // strings as Glicko ratings rather than as a literal rank label.
      final asNumber = num.tryParse(rankString);
      if (asNumber == null) {
        if (lower.endsWith('k') || lower.endsWith('d') || lower.endsWith('p')) {
          return rankString;
        }
      }
    }
    if (rating != null) return fromRating(rating);
    return null;
  }
}
