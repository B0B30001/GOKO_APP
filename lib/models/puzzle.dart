class Puzzle {
  final String id;
  final String title;
  final String description;
  final String category; // 'capture', 'life_death', 'tesuji', etc.
  final int difficulty; // 1-5
  final int boardSize;
  final List<List<int>> initialBoard; // 0=empty, 1=black, 2=white
  final int playerColor; // 1=black, 2=white (who should play)
  final List<PuzzleMove> solution;
  final String hint;
  final String explanation; // Explains why the solution works

  Puzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.boardSize,
    required this.initialBoard,
    required this.playerColor,
    required this.solution,
    required this.hint,
    this.explanation = '',
  });
}

class PuzzleMove {
  final int row;
  final int col;
  final int color;

  PuzzleMove(this.row, this.col, this.color);
}

class PuzzleData {
  // Sample puzzles for different topics
  static List<Puzzle> getPuzzlesForTopic(String topic) {
    switch (topic) {
      case 'Captures':
        return _capturePuzzles;
      case 'Liberties':
        return _libertyPuzzles;
      case 'Life & Death':
        return _lifeDeathPuzzles;
      case 'Ko Basics':
        return _koPuzzles;
      default:
        return [];
    }
  }

  // Simple capture puzzles
  static final List<Puzzle> _capturePuzzles = [
    Puzzle(
      id: 'capture_1',
      title: 'Simple Capture',
      description: 'Capture the white stone by removing its last liberty',
      category: 'capture',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 2, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 1, 1)],
      hint: 'Look for the white stone with only one liberty remaining',
      explanation:
          '''The white stone at (3,2) has only one liberty at (3,1). Playing there captures it immediately.

Key Learning Points:
• Liberties are empty intersections directly adjacent to stones (not diagonal)
• When all liberties are filled by the opponent, the stone is captured
• Always count your liberties and your opponent's!

This is the most fundamental concept in Go - understanding liberties is essential for all tactics.''',
    ),
    Puzzle(
      id: 'capture_2',
      title: 'Two Stone Capture',
      description: 'Capture two white stones in a row',
      category: 'capture',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 2, 2, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 1, 1)],
      hint: 'Find where both white stones share their last liberty',
      explanation:
          '''Both white stones share one liberty at (3,1). Capturing them together demonstrates an important principle.

Key Learning Points:
• Connected stones (touching horizontally or vertically) share liberties
• They form one group and are captured as a unit
• Larger groups can have more liberties than individual stones
• But they can also be captured all at once!

Understanding group connectivity is crucial for both attack and defense.''',
    ),
    Puzzle(
      id: 'capture_3',
      title: 'Corner Capture',
      description: 'Use the corner to trap white stones',
      category: 'capture',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [2, 2, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [1, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(1, 0, 1)],
      hint: 'The corner limits white\'s liberties',
      explanation:
          '''In the corner, stones have fewer liberties. Playing at (1,0) captures the two white stones.

Key Learning Points:
• Corner stones start with only 2 liberties (vs 4 in the center)
• Edge stones have 3 liberties
• The board edge acts like an opponent's stone
• Corners and edges are easier to attack but also easier to defend

"Corners first, then sides, then center" is an ancient Go proverb reflecting this principle.''',
    ),
    Puzzle(
      id: 'capture_4',
      title: 'Net Capture',
      description: 'Surround white stones without touching them directly',
      category: 'capture',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 2, 0, 1, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(2, 3, 1)],
      hint: 'You don\'t need to touch the stone to capture it',
      explanation:
          '''This is called a "net" (geta in Japanese) - the white stone cannot escape the surrounding black stones.

Key Learning Points:
• Not all captures require direct contact
• A net traps stones by controlling all escape routes
• The trapped stone has nowhere to run in any direction
• This technique is more efficient than chasing with direct contact

The net is one of the most beautiful and fundamental capturing techniques in Go. It shows that Go is about control, not just contact.''',
    ),
  ];

  // Liberty counting puzzles
  static final List<Puzzle> _libertyPuzzles = [
    Puzzle(
      id: 'liberty_1',
      title: 'Count Liberties - Single Stone',
      description: 'This black stone has 4 liberties',
      category: 'liberties',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint: 'Count up, down, left, and right from the stone',
      explanation:
          '''A single stone in the center has 4 liberties (one in each direction).

Key Learning Points:
• Liberties are orthogonal (horizontal/vertical), never diagonal
• Center stones have the maximum 4 liberties
• Corner stones have only 2 liberties
• Edge stones have 3 liberties
• Empty points count as liberties

Liberty counting is the foundation of all Go tactics. Master this and you master the fundamentals!''',
    ),
    Puzzle(
      id: 'liberty_2',
      title: 'Connected Stones Share Liberties',
      description: 'This black group has 6 liberties total',
      category: 'liberties',
      difficulty: 1,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint: 'Connected stones form one group and share liberties',
      explanation: '''The 3 black stones form one group with 6 total liberties.

Key Learning Points:
• Stones connected horizontally or vertically form ONE group
• The group shares all liberties - count them all together
• Some liberties belong to multiple stones in the group
• Strong groups have many liberties
• The more liberties a group has, the safer it is

When counting liberties for a group, mark each empty adjacent point only once, even if multiple stones touch it.''',
    ),
    Puzzle(
      id: 'liberty_3',
      title: 'Reduce Liberties to Capture',
      description: 'White has 2 liberties. Reduce to 1 for atari!',
      category: 'liberties',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [0, 1, 2, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(2, 1, 1)],
      hint: 'Play next to the white stone to reduce its liberties',
      explanation:
          '''Reducing liberties puts pressure on enemy stones. After this move, the next move will capture!

Key Learning Points:
• "Atari" means a stone/group has only 1 liberty left
• It's like "check" in chess - a warning of imminent capture
• The opponent must either escape or defend
• Reducing liberties step-by-step is how you attack groups
• When you reduce to 1 liberty, shout "Atari!" (optional but fun!)

Atari is one of the first Go terms beginners learn. It signals danger!''',
    ),
  ];

  // Life and Death puzzles
  static final List<Puzzle> _lifeDeathPuzzles = [
    Puzzle(
      id: 'life_death_1',
      title: 'Make Two Eyes',
      description: 'Secure life by making two eyes',
      category: 'life_death',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 2, 2, 2, 2, 0, 0, 0, 0],
        [0, 2, 1, 1, 2, 0, 0, 0, 0],
        [0, 2, 0, 0, 2, 0, 0, 0, 0],
        [0, 0, 2, 2, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 2, 1)],
      hint: 'Divide the interior space to create two separate eyes',
      explanation:
          '''A group with two eyes cannot be captured. Playing at (3,2) creates two separate eyes.

Key Learning Points:
• An "eye" is an empty intersection completely surrounded by your stones
• Two eyes = unconditional life (cannot be killed)
• One eye = can usually be killed
• False eyes collapse when attacked properly
• This is THE most important concept for survival

The proverb says: "Two eyes live, one eye dies." When defending, always aim to create two eyes. When attacking, prevent your opponent from making two eyes!''',
    ),
    Puzzle(
      id: 'life_death_2',
      title: 'Kill White',
      description: 'Prevent white from making two eyes',
      category: 'life_death',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 1, 1, 0, 0, 0, 0],
        [0, 1, 2, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 2, 1, 0, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(2, 3, 1)],
      hint: 'Play in the vital point that prevents eye formation',
      explanation:
          '''By playing at (2,3), white cannot make two eyes and the group dies.

Key Learning Points:
• The "vital point" is the key spot for both making and preventing eyes
• Playing here prevents the opponent from creating two eyes
• Life and death often comes down to who plays the vital point first
• Reading ahead is essential - can the opponent make two eyes?
• Practice makes perfect - these patterns become second nature

In Go, this is called a "killing move" (tesuji). Finding it requires careful reading and pattern recognition.''',
    ),
    Puzzle(
      id: 'life_death_3',
      title: 'Corner Life',
      description: 'Defend the corner by making life',
      category: 'life_death',
      difficulty: 3,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [1, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 1, 2, 0, 0, 0, 0, 0, 0],
        [1, 2, 0, 0, 0, 0, 0, 0, 0],
        [2, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(0, 1, 1)],
      hint: 'Find the move that creates two eyes in the corner',
      explanation: '''Playing at (0,1) secures the corner with two eyes.

Key Learning Points:
• Corners have unique life & death patterns
• Less space = harder to make two eyes
• But corners are also easier to defend efficiently
• Many famous life & death problems focus on corners
• Learning corner patterns gives you a huge advantage

"In the corner, seven die but eight live" is a famous Go proverb about a specific corner pattern. Corner life & death is a rich study area!''',
    ),
  ];

  // Ko puzzles
  static final List<Puzzle> _koPuzzles = [
    Puzzle(
      id: 'ko_1',
      title: 'Ko Recognition',
      description: 'Identify and capture in a Ko situation',
      category: 'ko',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 1, 0, 1, 2, 0, 0, 0, 0],
        [0, 0, 1, 2, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [PuzzleMove(3, 2, 1)],
      hint: 'This is a repeating pattern where you can capture back and forth',
      explanation:
          '''Ko is a situation where capturing and recapturing would repeat forever. Go rules prevent immediate recapture.

Key Learning Points:
• Ko (劫) means "eternity" or "kalpa" in Japanese/Chinese
• The Ko rule prevents infinite loops in the game
• After capturing in Ko, you must play elsewhere first
• Ko fights can decide entire games
• "Ko threats" are moves your opponent must respond to

Ko is one of Go's most sophisticated rules. It adds strategic depth by forcing players to find urgent moves elsewhere on the board.''',
    ),
    Puzzle(
      id: 'ko_2',
      title: 'Understand Ko Rule',
      description: 'Why you cannot immediately recapture in Ko',
      category: 'ko',
      difficulty: 2,
      boardSize: 9,
      initialBoard: _createBoard9x9([
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 1, 2, 0, 2, 1, 0, 0, 0],
        [0, 0, 1, 2, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]),
      playerColor: 1,
      solution: [],
      hint: 'After capturing in Ko, you must play elsewhere before recapturing',
      explanation:
          '''The Ko rule prevents infinite loops by requiring a move elsewhere before recapturing.

Key Learning Points:
• Immediate recapture in Ko is illegal
• You must play at least one move elsewhere first
• Then you can recapture if your opponent didn't fill the Ko
• Ko fights involve "Ko threats" - urgent moves forcing a response
• The player with better Ko threats often wins the Ko battle

Professional games have been decided by Ko fights. Understanding Ko deeply separates beginners from advanced players!''',
    ),
  ];

  static List<List<int>> _createBoard9x9(List<List<int>> board) {
    return board;
  }
}
