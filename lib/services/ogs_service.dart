import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'online/websocket_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'online/active_games_repository.dart';

/// OGS Service - handles authentication and API calls
/// Uses simple username/password authentication like Sente Go
class OgsService extends ChangeNotifier {
  String? _chatAuth;
  String? _jwt; // JWT token for WebSocket authentication
  Map<String, dynamic>? _userData;

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

  /// Disconnect from WebSocket
  void disconnect() {
    _wsService.disconnect();
  }

  /// Logout - clear all session data
  void logout() {
    disconnect();
    _userData = null;
    _chatAuth = null;
    _jwt = null;
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
