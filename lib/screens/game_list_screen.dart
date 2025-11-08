import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ogs_service.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);

    final ogsService = Provider.of<OgsService>(context, listen: false);
    final games = await ogsService.fetchOpenGames();

    setState(() {
      _games = games;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ogsService = Provider.of<OgsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Games on OGS'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGames),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ogsService.logout();
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No open games available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadGames,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadGames,
              child: ListView.builder(
                itemCount: _games.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return _buildGameCard(context, game);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Create a new game challenge
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create game - Coming soon')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Game'),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final challenger = game['challenger'] ?? {};
    final gameRules = game['game'] ?? {};
    final boardSize = gameRules['width'] ?? 19;
    final timeControl = game['time_control'] ?? {};

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '${boardSize}×$boardSize',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'vs ${challenger['username'] ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Board: ${boardSize}×$boardSize'),
            Text(
              'Time: ${_formatTimeControl(timeControl)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _joinGame(context, game),
      ),
    );
  }

  String _formatTimeControl(Map<String, dynamic> tc) {
    final system = tc['system'] ?? 'none';
    if (system == 'none') return 'No time limit';

    final timePerMove = tc['time_per_move'] ?? 0;
    if (timePerMove > 0) {
      return '${timePerMove}s per move';
    }

    final initialTime = tc['initial_time'] ?? 0;
    final timeIncrement = tc['time_increment'] ?? 0;

    if (initialTime > 0) {
      final minutes = (initialTime / 60).floor();
      return '${minutes}m + ${timeIncrement}s';
    }

    return 'Custom';
  }

  void _joinGame(BuildContext context, Map<String, dynamic> game) {
    final gameId = game['game_id'] ?? game['id'];

    if (gameId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid game ID')));
      return;
    }

    final ogsService = Provider.of<OgsService>(context, listen: false);

    // Connect to the game via socket
    if (ogsService.socket == null) {
      ogsService.connect();
    }

    ogsService.joinGame(gameId);

    // Navigate to the game board
    Navigator.pushNamed(
      context,
      '/game_board',
      arguments: {'gameId': gameId, 'isOnline': true},
    );
  }
}
