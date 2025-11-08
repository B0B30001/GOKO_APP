import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:convert';

// OGS OAuth2 Configuration
const String ogsClientId = 'cWdZPCV6jbYUzqeWdoAGYuklXDcgLGHNSisPzRp1';
const String ogsClientSecret =
    'pbkdf2_sha256\$870000\$D9IrathOPN53DUfjdyYiHn\$5TwoDTLOD93mw9jOgc55m5sNtJh8EmhoGR+5T0qiIts=';
const String ogsRedirectUri = 'https://b0b30001.github.io/zaibal_app/oauth2callback';
const String ogsAuthUrl = 'https://online-go.com/oauth2/authorize';
const String ogsTokenUrl = 'https://online-go.com/oauth2/token';
const String ogsApiBase = 'https://online-go.com/api/v1';

class OgsService extends ChangeNotifier {
  IO.Socket? socket;
  String? _accessToken;
  Map<String, dynamic>? _userData;
  StreamSubscription? _linkSubscription;
  final _appLinks = AppLinks();

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _accessToken != null;

  OgsService() {
    _initDeepLinking();
  }

  void _initDeepLinking() {
    // Listen for deep links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        if (uri.scheme == 'zaibalgo') {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    final code = uri.queryParameters['code'];
    if (code != null) {
      await _exchangeCodeForToken(code);
    }
  }

  // Step 1: Authenticate the user via OAuth2
  Future<bool> login() async {
    try {
      // Build the OAuth2 authorization URL
      final authUrl = Uri.https('online-go.com', '/oauth2/authorize', {
        'client_id': ogsClientId,
        'redirect_uri': ogsRedirectUri,
        'response_type': 'code',
        'scope': 'read write',
      });

      // Open the browser for user login
      final canLaunch = await canLaunchUrl(authUrl);
      if (!canLaunch) {
        debugPrint('Cannot launch URL');
        return false;
      }

      await launchUrl(authUrl, mode: LaunchMode.externalApplication,
      );

      // The deep link handler will receive the callback
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    try {
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
        notifyListeners();

        debugPrint('Login successful!');
      } else {
        debugPrint('Failed to get access token: ${tokenResponse.body}');
      }
    } catch (e) {
      debugPrint('Token exchange error: $e');
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

    socket = IO.io('https://online-go.com/socket.io', <String, dynamic>{
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
        Uri.https('online-go.com', '/api/v1/games/open'),
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
  Future<bool> joinGame(int gameId) async {
    if (_accessToken == null) return false;

    try {
      final response = await http.post(
        Uri.https('online-go.com', '/api/v1/games/$gameId/join'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        // Connect to the game via socket if not already connected
        if (socket == null) {
          connect();
        }
        
        // Join the game room
        socket?.emit('game/connect', {'game_id': gameId});
        return true;
      }
    } catch (e) {
      print('Failed to join game: $e');
    }
    return false;
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

  @override
  void dispose() {
    _linkSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}
