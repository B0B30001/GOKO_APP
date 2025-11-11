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
  List<OnlineGame> _cachedGames = [];

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
  });

  factory OnlineGame.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
