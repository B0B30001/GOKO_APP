import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/ogs_service.dart';
import '../../services/online/active_games_repository.dart';
import '../../utils/ogs_rank.dart';
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
  int? _etaSeconds;
  int? _queuePosition;
  int? _poolSize;
  final List<StreamSubscription> _automatchSubs = [];

  @override
  void dispose() {
    _detachAutomatchListeners();
    super.dispose();
  }

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
                _buildOgsProfileHeader(ogsService),
                _buildQuickPlaySection(ogsService),
                const Divider(),
                _buildActiveGamesSection(ogsService),
              ],
            ),
    );
  }

  Widget _buildOgsProfileHeader(OgsService ogs) {
    final username = ogs.username ?? 'OGS Player';
    final rank = OgsRank.bestLabel(
      rankString: ogs.rankString,
      rating: ogs.rating,
    );
    final rating = ogs.rating;
    final avatarUrl = ogs.avatarUrl;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primary.withValues(alpha: 0.25),
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Icon(Icons.person, color: cs.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (rating != null)
                  Text(
                    'Rating ${rating.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (rank != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                rank,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
              Text(_buildSearchingText()),
              if (_etaSeconds != null ||
                  _queuePosition != null ||
                  _poolSize != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (_etaSeconds != null)
                      Chip(
                        label: Text('ETA ~ ${_fmtEta(_etaSeconds!)}'),
                        avatar: const Icon(Icons.schedule, size: 18),
                      ),
                    if (_queuePosition != null)
                      Chip(
                        label: Text('Queue #${_queuePosition}'),
                        avatar: const Icon(Icons.people, size: 18),
                      ),
                    if (_poolSize != null)
                      Chip(
                        label: Text('Pool ${_poolSize}'),
                        avatar: const Icon(Icons.group, size: 18),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  if (_currentMatchId != null) {
                    ogsService.cancelAutomatch(_currentMatchId!);
                  }
                  _detachAutomatchListeners();
                  setState(() {
                    _isSearching = false;
                    _currentMatchId = null;
                    _etaSeconds = null;
                    _queuePosition = null;
                    _poolSize = null;
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
            if (game.timeControlDisplay != null || game.speed != null)
              Text(
                [
                  if (game.speed != null) game.speed!.toUpperCase(),
                  if (game.timeControlDisplay != null) game.timeControlDisplay!,
                ].join(' • '),
                style: TextStyle(color: Colors.grey[700]),
              ),
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
      _etaSeconds = null;
      _queuePosition = null;
      _poolSize = null;
    });

    ogsService.startAutomatch(sizes: [size], speed: 'live').then((uuid) {
      setState(() {
        _currentMatchId = uuid;
      });
      _attachAutomatchListeners(ogsService);
    });

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
              _etaSeconds = null;
              _queuePosition = null;
              _poolSize = null;
            });
            _detachAutomatchListeners();

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
              _etaSeconds = null;
              _queuePosition = null;
              _poolSize = null;
            });
            _detachAutomatchListeners();
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

  void _attachAutomatchListeners(OgsService ogs) {
    // Track ETA/status updates from various possible OGS event names
    void handleEstimate(dynamic data) {
      try {
        if (data is Map) {
          final eta = data['eta'] ?? data['estimate'] ?? data['estimated'];
          final pos = data['position'] ?? data['queue_position'];
          final pool =
              data['pool'] ?? data['players_in_pool'] ?? data['active_players'];
          setState(() {
            if (eta is int) _etaSeconds = eta;
            if (eta is String) _etaSeconds = int.tryParse(eta);
            if (pos is int) _queuePosition = pos;
            if (pos is String) _queuePosition = int.tryParse(pos);
            if (pool is int) _poolSize = pool;
            if (pool is String) _poolSize = int.tryParse(pool);
          });
        }
      } catch (_) {}
    }

    _automatchSubs.add(
      ogs.webSocketService
          .on<dynamic>('automatch/estimate')
          .listen(handleEstimate),
    );
    _automatchSubs.add(
      ogs.webSocketService
          .on<dynamic>('automatch/status')
          .listen(handleEstimate),
    );
    _automatchSubs.add(
      ogs.webSocketService
          .on<dynamic>('automatch/update')
          .listen(handleEstimate),
    );
    _automatchSubs.add(
      ogs.webSocketService
          .on<dynamic>('automatch/candidates')
          .listen(handleEstimate),
    );
  }

  void _detachAutomatchListeners() {
    for (final sub in _automatchSubs) {
      sub.cancel();
    }
    _automatchSubs.clear();
  }

  String _fmtEta(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m${s.toString().padLeft(2, '0')}s';
  }

  String _buildSearchingText() {
    if (_etaSeconds == null) return 'Searching for opponent…';
    return 'Searching for opponent… ~${_fmtEta(_etaSeconds!)}';
  }
}
