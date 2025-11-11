import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/ogs_service.dart';
import '../../services/online/active_games_repository.dart';
import 'online_game_screen.dart';
import 'connection_test_screen.dart';

class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  bool _isSearching = false;
  String? _currentMatchId;

  @override
  Widget build(BuildContext context) {
    final ogsService = Provider.of<OgsService>(context);
    final isConnected = ogsService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Play'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Connection Test',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectionTestScreen(),
                ),
              );
            },
          ),
          StreamBuilder<bool>(
            stream: ogsService.connectionState,
            builder: (context, snapshot) {
              final connected = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Icon(
                      connected ? Icons.cloud_done : Icons.cloud_off,
                      color: connected ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connected ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: connected ? Colors.green : Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: !isConnected
          ? _buildNotLoggedIn()
          : Column(
              children: [
                _buildQuickPlaySection(ogsService),
                const Divider(),
                _buildActiveGamesSection(ogsService),
              ],
            ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Not logged in',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Please log in with OGS to play online'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPlaySection(OgsService ogsService) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Quick Match',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Find an opponent instantly for a quick game'),
            const SizedBox(height: 16),
            if (_isSearching) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Searching for opponent...'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  if (_currentMatchId != null) {
                    ogsService.cancelAutomatch(_currentMatchId!);
                  }
                  setState(() {
                    _isSearching = false;
                    _currentMatchId = null;
                  });
                },
                child: const Text('Cancel'),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startQuickMatch(ogsService, '9x9'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('9×9 Game'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startQuickMatch(ogsService, '13x13'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('13×13 Game'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startQuickMatch(ogsService, '19x19'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('19×19 Game (Standard)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGamesSection(OgsService ogsService) {
    return Expanded(
      child: StreamBuilder<List<OnlineGame>>(
        stream: ogsService.activeGamesRepository.activeGames,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.games_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active games',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Start a quick match to begin!'),
                ],
              ),
            );
          }

          final games = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Active Games (${games.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _buildGameCard(game);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameCard(OnlineGame game) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: game.isMyTurn ? Colors.green : Colors.grey,
          child: Icon(
            game.isMyTurn ? Icons.notifications_active : Icons.hourglass_empty,
            color: Colors.white,
          ),
        ),
        title: Text(
          game.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${game.blackPlayerName} vs ${game.whitePlayerName}'),
            Text('${game.width}×${game.height} • Move ${game.moveNumber}'),
            if (game.isMyTurn)
              const Text(
                'Your turn!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: game.isMyTurn ? Colors.green : Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OnlineGameScreen(gameId: game.id),
            ),
          );
        },
      ),
    );
  }

  void _startQuickMatch(OgsService ogsService, String size) {
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ USER INITIATED QUICK MATCH                                 ║',
    );
    debugPrint(
      '╠════════════════════════════════════════════════════════════╣',
    );
    debugPrint('║ Board Size: $size');
    debugPrint('║ Speed: live');
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    setState(() {
      _isSearching = true;
      _currentMatchId = DateTime.now().millisecondsSinceEpoch.toString();
    });

    ogsService.startAutomatch(sizes: [size], speed: 'live');

    // Listen for game start
    debugPrint('🔔 Listening for automatch/start event...');
    ogsService.webSocketService
        .on<Map<String, dynamic>>('automatch/start')
        .first
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            debugPrint('⏱️ Automatch timeout - no response after 60 seconds');
            throw TimeoutException('Matchmaking timeout');
          },
        )
        .then((data) {
          debugPrint(
            '╔════════════════════════════════════════════════════════════╗',
          );
          debugPrint(
            '║ ✓ MATCH FOUND!                                             ║',
          );
          debugPrint(
            '╠════════════════════════════════════════════════════════════╣',
          );
          debugPrint('║ Data: $data');
          debugPrint(
            '╚════════════════════════════════════════════════════════════╝',
          );

          if (mounted) {
            setState(() {
              _isSearching = false;
              _currentMatchId = null;
            });

            final gameId = data['game_id']?.toString();
            if (gameId != null) {
              debugPrint('✅ Navigating to game: $gameId');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnlineGameScreen(gameId: gameId),
                ),
              );
            } else {
              debugPrint('❌ No game_id in response!');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: No game ID received')),
              );
            }
          }
        })
        .catchError((error) {
          debugPrint('❌ Automatch error: $error');
          if (mounted) {
            setState(() {
              _isSearching = false;
              _currentMatchId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Matchmaking failed: $error')),
            );
          }
        });

    // Also show a status message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Searching for opponent...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
