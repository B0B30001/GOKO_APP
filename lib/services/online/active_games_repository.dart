import 'dart:async';
import 'package:flutter/foundation.dart';
import 'websocket_service.dart';
import 'game_connection.dart';

/// Repository for managing active online games
/// Based on Sente Go's ActiveGamesRepository
class ActiveGamesRepository implements SocketConnectedRepository {
  final WebSocketService _socketService;

  final Map<String, GameConnection> _gameConnections = {};
  final StreamController<List<OnlineGame>> _activeGamesController =
      StreamController<List<OnlineGame>>.broadcast();

  Stream<List<OnlineGame>> get activeGames => _activeGamesController.stream;
  final List<OnlineGame> _cachedGames = [];

  ActiveGamesRepository(this._socketService) {
    _socketService.registerRepository(this);
  }

  @override
  void onSocketConnected() {
    debugPrint(
      '[ActiveGamesRepository] Socket connected - fetching active games',
    );
    _fetchActiveGames();
    _listenToActiveGameUpdates();
  }

  @override
  void onSocketDisconnected() {
    debugPrint('[ActiveGamesRepository] Socket disconnected');
    _gameConnections.clear();
  }

  void _fetchActiveGames() {
    _socketService.emit('gamelist/query', {
      'list': 'live',
      'from': 0,
      'limit': 50,
    });
  }

  void _listenToActiveGameUpdates() {
    _socketService.on<Map<String, dynamic>>('active_game').listen((data) {
      final game = OnlineGame.fromJson(data);
      debugPrint('[ActiveGamesRepository] Active game update: ${game.id}');

      _updateGameInCache(game);
      _activeGamesController.add(_cachedGames);
    });
  }

  void _updateGameInCache(OnlineGame game) {
    final index = _cachedGames.indexWhere((g) => g.id == game.id);
    if (index != -1) {
      _cachedGames[index] = game;
    } else {
      _cachedGames.add(game);
    }
  }

  /// Connect to a specific game
  GameConnection connectToGame(String gameId, {bool includeChat = true}) {
    if (_gameConnections.containsKey(gameId)) {
      final connection = _gameConnections[gameId]!;
      connection.connect();
      return connection;
    }

    final connection = GameConnection(
      gameId: gameId,
      socketService: _socketService,
      includeChat: includeChat,
    );

    _gameConnections[gameId] = connection;
    connection.connect();

    return connection;
  }

  /// Disconnect from a game
  void disconnectFromGame(String gameId) {
    final connection = _gameConnections[gameId];
    if (connection != null) {
      connection.disconnect();
      _gameConnections.remove(gameId);
    }
  }

  /// Get my turn games
  List<OnlineGame> get myTurnGames {
    return _cachedGames.where((game) => game.isMyTurn).toList()
      ..sort((a, b) => a.timeRemaining.compareTo(b.timeRemaining));
  }

  void dispose() {
    for (var connection in _gameConnections.values) {
      connection.dispose();
    }
    _gameConnections.clear();
    _activeGamesController.close();
  }
}

/// Online game model
class OnlineGame {
  final String id;
  final String name;
  final int width;
  final int height;
  final String phase;
  final String blackPlayerName;
  final String whitePlayerName;
  final int moveNumber;
  final bool isMyTurn;
  final int timeRemaining;
  final String? speed; // live/blitz/correspondence (if available)
  final String? timeControlDisplay; // e.g., "Byoyomi 10:00 + 5x30s"

  OnlineGame({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.phase,
    required this.blackPlayerName,
    required this.whitePlayerName,
    required this.moveNumber,
    required this.isMyTurn,
    required this.timeRemaining,
    this.speed,
    this.timeControlDisplay,
  });

  factory OnlineGame.fromJson(Map<String, dynamic> json) {
    String? speed;
    String? tcDisplay;
    final tc = json['time_control'];
    if (tc is Map) {
      // Common OGS fields: system, speed, main_time, period_time, periods, time_increment
      final system = tc['system']?.toString();
      speed = tc['speed']?.toString();
      final main = (tc['main_time'] ?? tc['initial_time'])?.toString();
      final periodTime = tc['period_time']?.toString();
      final periods = tc['periods']?.toString();
      final increment = tc['time_increment']?.toString();
      // Build a friendly display string
      if (system == 'byoyomi' &&
          main != null &&
          periodTime != null &&
          periods != null) {
        tcDisplay =
            'Byoyomi ${_fmtSeconds(main)} + $periods×${_fmtSeconds(periodTime)}';
      } else if (system == 'fischer' && main != null && increment != null) {
        tcDisplay = 'Fischer ${_fmtSeconds(main)} + ${_fmtSeconds(increment)}';
      } else if (main != null) {
        tcDisplay = '${system ?? 'clock'} ${_fmtSeconds(main)}';
      }
    }
    return OnlineGame(
      id: json['id'].toString(),
      name: json['name'] ?? 'Untitled Game',
      width: json['width'] ?? 19,
      height: json['height'] ?? 19,
      phase: json['phase'] ?? 'play',
      blackPlayerName: json['black']?['username'] ?? 'Black',
      whitePlayerName: json['white']?['username'] ?? 'White',
      moveNumber: json['move_number'] ?? 0,
      isMyTurn: json['is_my_turn'] ?? false,
      timeRemaining: json['time_remaining'] ?? 0,
      speed: speed ?? json['speed']?.toString(),
      timeControlDisplay: tcDisplay,
    );
  }
}

String _fmtSeconds(String secondsLike) {
  int secs = 0;
  try {
    secs = int.parse(secondsLike);
  } catch (_) {}
  final m = (secs ~/ 60).toString();
  final s = (secs % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
