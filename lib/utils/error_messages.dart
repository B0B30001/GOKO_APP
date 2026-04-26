/// Maps raw server error strings to friendly user-facing messages.
/// This is a best-effort mapper covering common OGS error codes/messages.
String mapGameError(String error) {
  final e = error.toLowerCase();

  // Turn-related
  if (e.contains('not_your_turn') || e.contains('out_of_turn')) {
    return "It's not your turn";
  }

  // Occupied / already placed
  if (e.contains('stone_already_placed_here') || e.contains('occupied')) {
    return 'A stone is already there';
  }

  // Illegal move umbrella
  if (e.contains('illegal_move')) {
    return 'Illegal move';
  }

  // Self-capture / suicide
  if (e.contains('self_capture') || e.contains('suicide')) {
    return 'Self-capture is not allowed';
  }

  // Ko violations
  if (e.contains('ko') && (e.contains('violation') || e.contains('illegal'))) {
    return 'Ko rule violation';
  }

  // Out of bounds
  if (e.contains('out_of_bounds')) {
    return 'Move is out of bounds';
  }

  // Game phase issues
  if (e.contains('game_is_not_in_play_phase') || e.contains('not in play')) {
    return 'Game is not in play phase';
  }

  // Busy / rate limit / server load
  if (e.contains('busy') || e.contains('rate limit')) {
    return 'Server is busy, please try again';
  }

  // Timeouts
  if (e.contains('timeout') || e.contains('out_of_time')) {
    return 'Out of time';
  }

  // Default
  return error;
}
