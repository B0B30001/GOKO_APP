import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'online/websocket_service.dart';
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

  OgsService() {
    activeGamesRepository = ActiveGamesRepository(_wsService);
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
  Future<void> startAutomatch({
    List<String> sizes = const ['9x9'],
    String speed = 'live',
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

    final matchData = {
      'uuid': DateTime.now().millisecondsSinceEpoch.toString(),
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
