import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

// TODO: Register your app on OGS to get these details
// Visit: https://online-go.com/oauth2/applications/registered/
const String ogsClientId = 'YOUR_OGS_CLIENT_ID';
const String ogsClientSecret = 'YOUR_OGS_CLIENT_SECRET';
const String ogsRedirectUri = 'com.zaibal.app://oauth2callback';

class OgsService extends ChangeNotifier {
  IO.Socket? socket;
  String? _accessToken;
  Map<String, dynamic>? _userData;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _accessToken != null;

  // Step 1: Authenticate the user via OAuth2
  Future<bool> login() async {
    try {
      // Build the OAuth2 authorization URL
      final authUrl = Uri.https('online-go.com', '/oauth2/authorize', {
        'client_id': ogsClientId,
        'redirect_uri': ogsRedirectUri,
        'response_type': 'code',
        'scope': 'openid profile email',
      });

      // Open the browser for user login
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'com.zaibal.app',
      );

      // Extract the authorization code from the callback
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        print('No authorization code received');
        return false;
      }

      // Exchange the code for an access token
      final tokenResponse = await http.post(
        Uri.https('online-go.com', '/oauth2/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': ogsRedirectUri,
          'client_id': ogsClientId,
          'client_secret': ogsClientSecret,
        },
      );

      if (tokenResponse.statusCode == 200) {
        final tokenData = json.decode(tokenResponse.body);
        _accessToken = tokenData['access_token'];

        // Fetch user profile
        await _fetchUserProfile();
        return true;
      } else {
        print('Failed to get access token: ${tokenResponse.body}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Fetch user profile from OGS
  Future<void> _fetchUserProfile() async {
    if (_accessToken == null) return;

    try {
      final response = await http.get(
        Uri.https('online-go.com', '/api/v1/me'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        _userData = json.decode(response.body);
        print('User profile: $_userData');
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  // Step 2: Connect to the OGS real-time server
  void connect() {
    if (_accessToken == null) {
      print('Cannot connect without being logged in.');
      return;
    }

    socket = IO.io('https://online-go.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {
        'Authorization': 'Bearer $_accessToken',
      },
    });

    socket!.onConnect((_) {
      print('Connected to OGS socket server');
      // Authenticate the socket connection
      socket!.emit('authenticate', {
        'auth': _accessToken,
        'player_id': _userData?['id'],
      });
    });

    socket!.on('gamedata', (data) {
      print('Received game data: $data');
      // TODO: Update your game state with this new data
    });

    socket!.on('game/move', (data) {
      print('Opponent made a move: $data');
      // TODO: Handle incoming moves
    });

    socket!.onDisconnect((_) => print('Disconnected from OGS'));

    socket!.onError((error) => print('Socket error: $error'));
  }

  // Fetch a list of open games
  Future<List<Map<String, dynamic>>> fetchOpenGames() async {
    if (_accessToken == null) return [];

    try {
      final response = await http.get(
        Uri.https('online-go.com', '/api/v1/challenges'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (e) {
      print('Error fetching open games: $e');
    }

    return [];
  }

  // Join a game
  void joinGame(int gameId) {
    if (socket == null) {
      print('Not connected to socket');
      return;
    }

    socket!.emit('game/connect', {
      'game_id': gameId,
    });
  }

  // Step 3: Send a move to the server
  void makeMove(int gameId, String move) {
    if (socket == null) {
      print('Not connected to socket');
      return;
    }

    socket!.emit('game/move', {
      'game_id': gameId,
      'move': move, // e.g., "c4", "pass"
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }

  void logout() {
    disconnect();
    _accessToken = null;
    _userData = null;
    notifyListeners();
  }
}
