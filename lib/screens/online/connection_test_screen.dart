import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ogs_service.dart';

/// Debug screen to test OGS WebSocket connection
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addLog('Connection Test Screen initialized');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(
        '[${DateTime.now().toLocal().toString().substring(11, 19)}] $message',
      );
    });
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _testConnection() {
    final ogsService = Provider.of<OgsService>(context, listen: false);

    _addLog('═══════════════════════════════════════');
    _addLog('STARTING CONNECTION TEST');
    _addLog('═══════════════════════════════════════');

    if (!ogsService.isAuthenticated) {
      _addLog('❌ NOT AUTHENTICATED');
      _addLog('Please login first!');
      return;
    }

    _addLog('✅ Authenticated as: ${ogsService.userData?['username']}');
    _addLog('User ID: ${ogsService.userData?['id']}');
    _addLog('Has chat_auth: ${ogsService.chatAuth != null}');

    // Listen to connection state
    ogsService.connectionState.listen((connected) {
      _addLog(
        connected ? '🟢 WebSocket CONNECTED' : '🔴 WebSocket DISCONNECTED',
      );
    });

    _addLog('Checking WebSocket service...');
    final ws = ogsService.webSocketService;
    _addLog('Is connected: ${ws.isConnected}');
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ogsService = Provider.of<OgsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Card(
            margin: const EdgeInsets.all(16),
            color: ogsService.isAuthenticated
                ? Colors.green.shade50
                : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        ogsService.isAuthenticated
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: ogsService.isAuthenticated
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ogsService.isAuthenticated
                            ? 'Authenticated'
                            : 'Not Authenticated',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (ogsService.isAuthenticated) ...[
                    const SizedBox(height: 8),
                    Text(
                      'User: ${ogsService.userData?['username'] ?? 'Unknown'}',
                    ),
                    Text('ID: ${ogsService.userData?['id'] ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    StreamBuilder<bool>(
                      stream: ogsService.connectionState,
                      builder: (context, snapshot) {
                        final connected = snapshot.data ?? false;
                        return Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: connected ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              connected
                                  ? 'WebSocket Connected'
                                  : 'WebSocket Disconnected',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Test Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.science),
                label: const Text('Run Connection Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Logs Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.terminal, size: 20),
                SizedBox(width: 8),
                Text(
                  'Debug Logs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        'No logs yet. Run a test to see output.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color textColor = Colors.white;

                        if (log.contains('✅') || log.contains('🟢')) {
                          textColor = Colors.greenAccent;
                        } else if (log.contains('❌') || log.contains('🔴')) {
                          textColor = Colors.redAccent;
                        } else if (log.contains('⚠️')) {
                          textColor = Colors.orangeAccent;
                        } else if (log.contains('═')) {
                          textColor = Colors.cyanAccent;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
