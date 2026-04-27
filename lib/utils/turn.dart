/// Returns the opposite player. 1 = black, 2 = white.
///
/// Any non-1 input returns 1, so callers can rely on a defined result even
/// for sentinel/uninitialized values.
int nextPlayer(int current) => current == 1 ? 2 : 1;
