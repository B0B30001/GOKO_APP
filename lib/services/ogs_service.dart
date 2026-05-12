import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'online/websocket_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'online/active_games_repository.dart';

/// OGS Service - handles authentication and API calls
/// Uses simple username/password authentication like Sente Go
class OgsService extends ChangeNotifier {
  String? _chatAuth;
  String? _jwt; // JWT token for WebSocket authentication
  Map<String, dynamic>? _userData;

  // Secure storage keys for persisted session tokens.
  static const _kUserData = 'ogs_user_data';
  static const _kChatAuth = 'ogs_chat_auth';
  static const _kJwt = 'ogs_jwt';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // WebSocket service for real-time functionality
  final WebSocketService _wsService = WebSocketService();
  late final ActiveGamesRepository activeGamesRepository;

  String? get chatAuth => _chatAuth;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _userData != null && _chatAuth != null;
  WebSocketService get webSocketService => _wsService;
  Stream<bool> get connectionState => _wsService.connectionState;

  // ----- OGS profile field accessors -----
  // The login response stores a `user` blob with these fields. Some are only
  // present on certain accounts (anonymous users, freshly created profiles),
  // so all getters are nullable. The numeric `ratings.overall.rating` is the
  // canonical Glicko-2 rating used for matchmaking.

  /// OGS user id (numeric).
  int? get userId {
    final v = _userData?['id'];
    return v is int ? v : (v is String ? int.tryParse(v) : null);
  }

  /// Username as shown on OGS.
  String? get username => _userData?['username']?.toString();

  /// OGS rank string (e.g. `'5k'`, `'2d'`). Comes from the `ranking` field
  /// when present; otherwise derive via [OgsRank.fromRating] on [rating].
  String? get rankString {
    final r = _userData?['ranking'];
    if (r == null) return null;
    return r.toString();
  }

  /// Numeric Glicko-2 rating. Returns null when OGS has not provided one yet.
  double? get rating {
    final ratings = _userData?['ratings'];
    if (ratings is Map) {
      final overall = ratings['overall'];
      if (overall is Map && overall['rating'] != null) {
        return (overall['rating'] as num).toDouble();
      }
    }
    final flat = _userData?['rating'];
    if (flat is num) return flat.toDouble();
    return null;
  }

  /// Avatar URL — OGS returns either a full URL or a Gravatar identifier in
  /// the `icon` field. Returns null if neither is present.
  String? get avatarUrl {
    final icon = _userData?['icon'];
    if (icon is String && icon.isNotEmpty) return icon;
    return null;
  }

  /// Two-letter country code, lowercase.
  String? get country => _userData?['country']?.toString();

  /// True when the OGS profile is flagged as a professional player.
  bool get isProfessional => _userData?['professional'] == true;

  // Simple game summary model for recent/finished games
  Future<List<GameSummary>> fetchRecentGames({int limit = 20}) async {
    if (_userData == null) return [];
    final userId = _userData!['id'];
    final headers = <String, String>{'Accept': 'application/json'};
    if (_jwt != null && _jwt!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwt';
    }
    final candidates = <Uri>[
      Uri.https('online-go.com', '/api/v1/players/$userId/games/', {
        'page_size': limit.toString(),
      }),
      Uri.https('online-go.com', '/api/v1/me/games/', {
        'page_size': limit.toString(),
      }),
    ];
    http.Response? response;
    for (final uri in candidates) {
      try {
        final r = await http.get(uri, headers: headers);
        if (r.statusCode == 200) {
          response = r;
          break;
        }
      } catch (_) {
        // try next
      }
    }
    if (response == null) return [];
    final data = json.decode(response.body);
    final results = <GameSummary>[];
    final items = (data is Map && data['results'] is List)
        ? (data['results'] as List)
        : (data is List ? data : const []);
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        results.add(GameSummary.fromJson(item, myId: userId));
      }
    }
    return results;
  }

  OgsService() {
    activeGamesRepository = ActiveGamesRepository(_wsService);
  }

  /// Attempts to restore a previously saved OGS session from secure storage.
  /// Called once at app startup in [main]; silently no-ops when no saved
  /// session exists or the stored data is invalid.
  Future<void> tryAutoLogin() async {
    try {
      final userDataStr = await _storage.read(key: _kUserData);
      final chatAuth = await _storage.read(key: _kChatAuth);
      final jwt = await _storage.read(key: _kJwt);
      if (userDataStr == null || chatAuth == null) return;
      final decoded = json.decode(userDataStr);
      if (decoded is! Map<String, dynamic>) return;
      _userData = decoded;
      _chatAuth = chatAuth;
      _jwt = jwt;
      // Reconnect WebSocket with stored credentials.
      _wsService.connect(
        userId: _userData!['id'].toString(),
        authToken: _chatAuth!,
        jwt: _jwt,
      );
      notifyListeners();
      debugPrint('OGS: auto-login restored for ${_userData!["username"]}');
    } catch (e) {
      // Corrupted storage — treat as logged out.
      debugPrint('OGS: auto-login failed: $e');
    }
  }

  /// Persists the current session tokens to secure storage.
  Future<void> _persistSession() async {
    if (_userData == null || _chatAuth == null) return;
    try {
      await _storage.write(key: _kUserData, value: json.encode(_userData));
      await _storage.write(key: _kChatAuth, value: _chatAuth!);
      if (_jwt != null) await _storage.write(key: _kJwt, value: _jwt!);
    } catch (e) {
      debugPrint('OGS: failed to persist session: $e');
    }
  }

  // OAuth config (set via --dart-define for client id in builds)
  static const String _ogsClientId = String.fromEnvironment(
    'OGS_CLIENT_ID',
    defaultValue: '',
  );
  static const String _ogsRedirectUri = 'com.zaibal.app://oauth2callback';
  static const String _ogsBase = 'https://online-go.com';

  /// Launch an external URL using system browser
  Future<void> launchExternalUrl(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Start OGS OAuth sign-in (user can pick Google/others on OGS)
  /// If client id is not configured, falls back to OGS login page.
  Future<void> startOgsOAuth() async {
    if (_ogsClientId.isEmpty) {
      // Fallback to OGS login page (offers Google/etc.)
      await launchExternalUrl(Uri.parse('$_ogsBase/login'));
      return;
    }
    final authUri = Uri.parse('$_ogsBase/oauth2/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': _ogsClientId,
        'redirect_uri': _ogsRedirectUri,
        'scope': 'read write ui_config',
      },
    );
    await launchExternalUrl(authUri);
  }

  /// Login with username and password (Sente Go style)
  /// POST /api/v0/login with JSON body containing username and password
  /// Returns UIConfig with csrf_token, user data, and chat_auth
  Future<bool> loginWithPassword(String username, String password) async {
    try {
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ OGS LOGIN ATTEMPT                                          ║',
      );
      debugPrint(
        '╠════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ Username: $username');
      debugPrint('║ Endpoint: https://online-go.com/api/v0/login');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );

      // Login endpoint from Sente: POST api/v0/login
      final loginResponse = await http.post(
        Uri.https('online-go.com', '/api/v0/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ LOGIN RESPONSE                                             ║',
      );
      debugPrint(
        '╠════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ Status Code: ${loginResponse.statusCode}');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );

      if (loginResponse.statusCode == 200) {
        final uiConfig = json.decode(loginResponse.body);

        debugPrint('Response keys: ${uiConfig.keys.toList()}');

        // Check if login was successful (Sente checks for csrf_token)
        if (uiConfig['csrf_token'] == null ||
            uiConfig['csrf_token'].toString().isEmpty) {
          debugPrint('❌ Login failed: no csrf_token');
          return false;
        }

        // Store user data and auth tokens
        _userData = uiConfig['user'];
        _chatAuth = uiConfig['chat_auth'];
        _jwt = uiConfig['user_jwt']; // Extract JWT for WebSocket authentication

        debugPrint(
          '╔════════════════════════════════════════════════════════════╗',
        );
        debugPrint(
          '║ ✓ LOGIN SUCCESSFUL!                                        ║',
        );
        debugPrint(
          '╠════════════════════════════════════════════════════════════╣',
        );
        debugPrint('║ Username: ${_userData?['username']}');
        debugPrint('║ User ID: ${_userData?['id']}');
        debugPrint('║ Rank: ${_userData?['ranking']}');
        debugPrint('║ Has chat_auth: ${_chatAuth != null}');
        debugPrint('║ Has JWT: ${_jwt != null}');
        debugPrint(
          '╚════════════════════════════════════════════════════════════╝',
        );

        // Connect WebSocket with user credentials
        if (_userData != null && _chatAuth != null) {
          _wsService.connect(
            userId: _userData!['id'].toString(),
            authToken: _chatAuth!,
            jwt: _jwt, // Pass JWT for proper OGS authentication
          );
        }

        // Persist session so the user stays logged in after restart.
        unawaited(_persistSession());

        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Login failed with status: ${loginResponse.statusCode}');
        debugPrint('Response body: ${loginResponse.body}');
        return false;
      }
    } catch (e) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ ✗ LOGIN ERROR                                              ║',
      );
      debugPrint(
        '╠════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ Error: $e');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      return false;
    }
  }

  /// Start automatch (quick game) - OGS protocol
  Future<String> startAutomatch({
    List<String> sizes = const ['9x9'],
    String speed = 'live',
    String? uuid,
  }) async {
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ STARTING AUTOMATCH (OGS Protocol)                          ║',
    );
    debugPrint(
      '╠════════════════════════════════════════════════════════════╣',
    );
    debugPrint('║ Sizes: $sizes');
    debugPrint('║ Speed: $speed');
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    final matchUuid = uuid ?? DateTime.now().millisecondsSinceEpoch.toString();
    final matchData = {
      'uuid': matchUuid,
      'size_speed_options': sizes
          .map((size) => {'size': size, 'speed': speed})
          .toList(),
      'lower_rank_diff': 6,
      'upper_rank_diff': 6,
      'rules': {'condition': 'no-preference', 'value': 'japanese'},
      'time_control': {
        'condition': 'no-preference',
        'value': {'system': 'byoyomi'},
      },
      'handicap': {'condition': 'no-preference', 'value': 'enabled'},
    };

    debugPrint('Match data: $matchData');
    // OGS protocol uses socket.send()
    _wsService.send('automatch/find_match', matchData);
    return matchUuid;
  }

  /// Cancel automatch (OGS protocol)
  void cancelAutomatch(String uuid) {
    _wsService.send('automatch/cancel', uuid);
  }

  // ---------------------------------------------------------------------------
  // Bot challenge API
  // ---------------------------------------------------------------------------

  /// Known OGS bot accounts mapped by display level.
  ///
  /// These are long-running community bots that accept challenges automatically.
  /// Ordered Easy → Hard within each board size family.
  static const Map<String, String> _botUsernames = {
    'easy': 'GnuGo',
    'medium': 'leela-one-click',
    'hard': 'katago-master-20',
  };

  /// Look up a player's numeric OGS id by username.
  ///
  /// Returns null if the request fails or the user is not found.
  Future<int?> findBotId(String username) async {
    try {
      final uri = Uri.https('online-go.com', '/api/v1/players/', {
        'username': username,
        'page_size': '3',
      });
      final headers = _authHeaders();
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) return null;
      final body = json.decode(resp.body);
      final results = body['results'];
      if (results is! List || results.isEmpty) return null;
      // Pick exact-match username (case-insensitive).
      for (final r in results) {
        if (r is Map &&
            r['username']?.toString().toLowerCase() == username.toLowerCase()) {
          final id = r['id'];
          return id is int ? id : int.tryParse('$id');
        }
      }
      // Fallback: first result.
      final first = results.first;
      if (first is Map) {
        final id = first['id'];
        return id is int ? id : int.tryParse('$id');
      }
    } catch (e) {
      debugPrint('OGS: findBotId($username) failed: $e');
    }
    return null;
  }

  /// Create a challenge against an OGS bot and wait for it to auto-accept.
  ///
  /// [botId] is the numeric player id of the bot (from [findBotId]).
  /// [boardSize] should be 9, 13, or 19.
  ///
  /// Returns the created game id on success, or null on failure.
  Future<int?> challengeBot(int botId, int boardSize) async {
    if (!isAuthenticated) return null;
    try {
      final headers = _authHeaders()..['Content-Type'] = 'application/json';
      final body = json.encode({
        'player': botId,
        'game': {
          'name': 'GOKO vs bot',
          'rules': 'japanese',
          'width': boardSize,
          'height': boardSize,
          'komi': 6.5,
          'handicap': 0,
          'time_control': 'byoyomi',
          'time_control_parameters': {
            'system': 'byoyomi',
            'speed': 'live',
            'main_time': 300,
            'period_time': 30,
            'periods': 3,
            'pause_on_weekends': false,
          },
          'initial_player': 'black',
          'private': false,
          'ranked': false,
          'aga_rated': false,
        },
      });
      final challengeResp = await http.post(
        Uri.https('online-go.com', '/api/v1/challenges/'),
        headers: headers,
        body: body,
      );
      if (challengeResp.statusCode != 200 && challengeResp.statusCode != 201) {
        debugPrint(
          'OGS: challengeBot failed: ${challengeResp.statusCode} '
          '${challengeResp.body}',
        );
        return null;
      }
      final challengeData = json.decode(challengeResp.body);
      // The challenge response includes `game` or `game_id`.
      final gameId = _extractGameId(challengeData);
      if (gameId != null) return gameId;

      // Some OGS versions require an explicit accept call.
      final challengeId = challengeData['id'];
      if (challengeId == null) return null;
      final acceptResp = await http.post(
        Uri.https('online-go.com', '/api/v1/challenges/$challengeId/accept/'),
        headers: headers,
      );
      if (acceptResp.statusCode == 200 || acceptResp.statusCode == 201) {
        final acceptData = json.decode(acceptResp.body);
        return _extractGameId(acceptData);
      }
    } catch (e) {
      debugPrint('OGS: challengeBot error: $e');
    }
    return null;
  }

  /// Returns the bot username for the given difficulty string ('easy',
  /// 'medium', 'hard').
  static String botUsernameForLevel(String level) =>
      _botUsernames[level] ?? _botUsernames['hard']!;

  Map<String, String> _authHeaders() {
    final headers = <String, String>{'Accept': 'application/json'};
    if (_jwt != null && _jwt!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwt';
    }
    return headers;
  }

  static int? _extractGameId(dynamic data) {
    if (data is! Map) return null;
    final game = data['game'];
    if (game is Map) {
      final id = game['id'];
      return id is int ? id : int.tryParse('$id');
    }
    final gameId = data['game_id'] ?? data['gameId'];
    if (gameId != null) {
      return gameId is int ? gameId : int.tryParse('$gameId');
    }
    return null;
  }

  // ---------------------------------------------------------------------------

  /// Disconnect from WebSocket
  void disconnect() {
    _wsService.disconnect();
  }

  /// Logout - clear all session data
  Future<void> logout() async {
    disconnect();
    _userData = null;
    _chatAuth = null;
    _jwt = null;
    // Remove persisted tokens so auto-login doesn't fire next launch.
    try {
      await _storage.deleteAll();
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _wsService.dispose();
    super.dispose();
  }
}

class GameSummary {
  final String id;
  final String opponent;
  final DateTime? ended;
  final int size;
  final String result; // e.g., "B+R", "W+7.5"
  final String score; // normalized from result when possible
  final bool didWin;

  GameSummary({
    required this.id,
    required this.opponent,
    required this.ended,
    required this.size,
    required this.result,
    required this.score,
    required this.didWin,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json, {required int myId}) {
    final id = json['id']?.toString() ?? '';
    final width = json['width'] ?? 19;
    final size = width is int ? width : 19;
    String opponent = 'Opponent';
    final black = json['black'];
    final white = json['white'];
    int? blackId;
    String blackName = 'Black';
    String whiteName = 'White';
    if (black is Map) {
      blackId = black['id'] is int
          ? black['id']
          : int.tryParse('${black['id']}');
      blackName = black['username']?.toString() ?? blackName;
    }
    if (white is Map) {
      whiteName = white['username']?.toString() ?? whiteName;
    }
    final amBlack = blackId == myId;
    opponent = amBlack ? whiteName : blackName;

    String result =
        json['outcome']?.toString() ?? json['result']?.toString() ?? '';
    if (result.isEmpty && json['score'] != null) {
      result = json['score'].toString();
    }
    String score = '';
    final lower = result.toLowerCase();
    bool didWin = false;
    if (lower.startsWith('b+') || lower.startsWith('w+')) {
      final winner = lower[0];
      didWin = (winner == 'b' && amBlack) || (winner == 'w' && !amBlack);
      score = result.contains('+') ? result.split('+').last : result;
    } else if (lower.contains('resign')) {
      // Try to parse winner
      if (lower.contains('black')) didWin = amBlack;
      if (lower.contains('white')) didWin = !amBlack;
      score = 'Resign';
    } else if (lower.contains('timeout')) {
      score = 'Timeout';
    } else if (lower.contains('draw')) {
      score = 'Draw';
    }

    DateTime? ended;
    final endedStr = json['ended']?.toString() ?? json['ended_at']?.toString();
    if (endedStr != null && endedStr.isNotEmpty) {
      try {
        ended = DateTime.parse(endedStr);
      } catch (_) {}
    }
    return GameSummary(
      id: id,
      opponent: opponent,
      ended: ended,
      size: size,
      result: result,
      score: score,
      didWin: didWin,
    );
  }
}
