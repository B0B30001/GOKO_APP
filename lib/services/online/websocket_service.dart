import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';

/// WebSocket service for real-time online multiplayer
/// Uses OGS WebSocket protocol: socket.send() instead of socket.emit()
/// Authentication requires JWT, device_id, user_agent, etc.
class WebSocketService {
  static const String baseUrl = 'https://online-go.com';
  static const String clientVersion = '1.0.0';

  IO.Socket? _socket;
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  bool get isConnected => _socket?.connected ?? false;
  Stream<bool> get connectionState => _connectionStateController.stream;

  final List<SocketConnectedRepository> _repositories = [];

  // Event listeners
  final Map<String, StreamController> _eventStreams = {};

  // Device ID for OGS authentication (persistent per device)
  static final String _deviceId = const Uuid().v4();

  // JWT token from login (required for OGS authentication)
  String? _jwt;

  WebSocketService();

  /// Set JWT token from login response
  void setJwt(String jwt) {
    _jwt = jwt;
    debugPrint('🔑 [WebSocket] JWT token stored: ${jwt.substring(0, 20)}...');
  }

  /// Initialize socket connection
  void connect({
    required String userId,
    required String authToken,
    String? jwt,
  }) {
    if (jwt != null) {
      _jwt = jwt;
    }
    if (_socket != null && _socket!.connected) {
      debugPrint('[WebSocket] Already connected');
      return;
    }

    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ WEBSOCKET CONNECTION STARTING                              ║',
    );
    debugPrint(
      '╠════════════════════════════════════════════════════════════╣',
    );
    debugPrint('║ URL: $baseUrl');
    debugPrint('║ User ID: $userId');
    debugPrint('║ Auth Token: ${authToken.substring(0, 10)}...');
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionDelay': 750,
      'reconnectionDelayMax': 10000,
      'timeout': 20000,
    });

    _socket!.onConnect((_) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ ✓ WEBSOCKET CONNECTED!                                     ║',
      );
      debugPrint(
        '╠════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ Socket ID: ${_socket!.id}');
      debugPrint('║ Status: CONNECTED');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      _connectionStateController.add(true);
      _authenticate(userId, authToken);
      _notifyRepositoriesConnected();
    });

    _socket!.onDisconnect((_) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ ✗ WEBSOCKET DISCONNECTED                                   ║',
      );
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      _connectionStateController.add(false);
      _notifyRepositoriesDisconnected();
    });

    _socket!.onConnectError((error) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ ✗ CONNECTION ERROR                                         ║',
      );
      debugPrint(
        '╠════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ Error: $error');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
    });

    _socket!.onError((error) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ ✗ WEBSOCKET ERROR                                          ║',
      );
      debugPrint(
        '╠════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ Error: $error');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
    });

    _socket!.connect();

    // Listen to all events for debugging
    _socket!.onAny((event, data) {
      debugPrint('🔊 [WebSocket] Event: $event | Data: $data');
    });
  }

  /// Disconnect from server
  void disconnect() {
    debugPrint('[WebSocket] Disconnecting...');
    _notifyRepositoriesDisconnected();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Authenticate with server using OGS protocol
  /// OGS requires: jwt, device_id, user_agent, language, language_version, client_version
  void _authenticate(String userId, String authToken) {
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ AUTHENTICATING WITH OGS (Real Protocol)                    ║',
    );
    debugPrint(
      '╠════════════════════════════════════════════════════════════╣',
    );
    debugPrint('║ User ID: $userId');
    debugPrint('║ JWT: ${_jwt?.substring(0, 20) ?? "MISSING"}...');
    debugPrint('║ Device ID: $_deviceId');
    debugPrint('║ Client Version: $clientVersion');
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    // OGS authentication requires these specific parameters
    final authData = {
      'jwt': _jwt ?? '', // JWT from login response
      'device_id': _deviceId, // Unique device identifier
      'user_agent': _getUserAgent(), // Platform user agent
      'language': 'en', // Current language
      'language_version': '1', // Translation version
      'client_version': clientVersion, // App version
    };

    debugPrint('Auth data: $authData');

    // OGS uses socket.send() for authentication, not emit()
    // Note: socket_io_client in Dart uses emit() which maps to send() in Socket.IO
    // The distinction is more important in the JavaScript client
    _socket!.emit('authenticate', authData);

    // Also listen for JWT updates from server
    _socket!.on('user/jwt', (data) {
      if (data is String) {
        debugPrint('🔑 [WebSocket] JWT updated from server');
        _jwt = data;
      }
    });
  }

  /// Get platform-specific user agent
  String _getUserAgent() {
    if (kIsWeb) {
      return 'Zaibal-Web/$clientVersion';
    } else {
      try {
        // Use dart:io only on non-web platforms
        return 'Zaibal-${Platform.operatingSystem}/$clientVersion (${Platform.operatingSystemVersion})';
      } catch (e) {
        return 'Zaibal-Mobile/$clientVersion';
      }
    }
  }

  /// Send event to server (OGS protocol uses "send" terminology)
  /// In socket_io_client for Dart, emit() is the correct method
  /// but conceptually OGS docs call this "send"
  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('⚠️ [WebSocket] Cannot send "$event" - NOT CONNECTED');
      return;
    }

    debugPrint('📤 [WebSocket] SEND ==> $event');
    debugPrint('   Data: $data');
    _socket!.emit(event, data);
  }

  /// Alias for emit to match OGS terminology
  void send(String event, dynamic data) => emit(event, data);

  /// Listen to server events
  Stream<T> on<T>(String event) {
    if (!_eventStreams.containsKey(event)) {
      _eventStreams[event] = StreamController<T>.broadcast();

      debugPrint('🔔 [WebSocket] Registered listener for: $event');

      _socket?.on(event, (data) {
        debugPrint('📥 [WebSocket] <== $event');
        debugPrint('   Data: $data');
        debugPrint('   Type: ${data.runtimeType}');
        _eventStreams[event]?.add(data);
      });
    }

    return (_eventStreams[event] as StreamController<T>).stream;
  }

  /// Register repository for connection lifecycle
  void registerRepository(SocketConnectedRepository repository) {
    _repositories.add(repository);
  }

  void _notifyRepositoriesConnected() {
    for (var repo in _repositories) {
      repo.onSocketConnected();
    }
  }

  void _notifyRepositoriesDisconnected() {
    for (var repo in _repositories) {
      repo.onSocketDisconnected();
    }
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    for (var controller in _eventStreams.values) {
      controller.close();
    }
    _eventStreams.clear();
  }
}

/// Interface for repositories that depend on socket connection
abstract class SocketConnectedRepository {
  void onSocketConnected();
  void onSocketDisconnected();
}
