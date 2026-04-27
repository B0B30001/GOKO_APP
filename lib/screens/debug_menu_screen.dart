import 'package:flutter/material.dart';
import '../services/dtd_service.dart';

class DebugMenuScreen extends StatefulWidget {
  const DebugMenuScreen({super.key});

  @override
  State<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends State<DebugMenuScreen> {
  final DtdService _dtdService = DtdService();
  final TextEditingController _uriController = TextEditingController();
  bool _isConnecting = false;

  @override
  void dispose() {
    _uriController.dispose();
    super.dispose();
  }

  Future<void> _connectToDtd() async {
    final uri = _uriController.text.trim();
    if (uri.isEmpty) {
      _showError('Please enter a DTD URI');
      return;
    }

    setState(() => _isConnecting = true);

    final success = await _dtdService.connect(uri);

    if (mounted) {
      setState(() => _isConnecting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Connected to DTD successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Failed to connect to DTD');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DTD Connection Instructions'),
        content: SingleChildScrollView(
          child: Text(
            DtdService.instructions,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
            tooltip: 'How to connect',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDtdSection(),
          const SizedBox(height: 24),
          _buildDebugActionsSection(),
          const SizedBox(height: 24),
          _buildDebugInfoSection(),
        ],
      ),
    );
  }

  Widget _buildDtdSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.developer_board,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dart Tooling Daemon',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _dtdService.isConnected ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _dtdService.isConnected ? 'Connected' : 'Not Connected',
                  style: TextStyle(
                    color: _dtdService.isConnected ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _uriController,
              decoration: const InputDecoration(
                labelText: 'DTD URI',
                hintText: 'ws://127.0.0.1:XXXXX/XXXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              enabled: !_dtdService.isConnected,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _dtdService.isConnected
                    ? () {
                        _dtdService.disconnect();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Disconnected from DTD'),
                          ),
                        );
                      }
                    : (_isConnecting ? null : _connectToDtd),
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_dtdService.isConnected ? 'Disconnect' : 'Connect'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.widgets),
              title: const Text('Enable Widget Inspector'),
              subtitle: const Text('Inspect widget tree in real-time'),
              trailing: Icon(
                _dtdService.isConnected ? Icons.check_circle : Icons.lock,
                color: _dtdService.isConnected ? Colors.green : Colors.grey,
              ),
              onTap: _dtdService.isConnected
                  ? () {
                      _dtdService.enableWidgetInspector();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Widget inspector enabled'),
                        ),
                      );
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Trigger Hot Reload'),
              subtitle: const Text('Reload app with code changes'),
              trailing: Icon(
                _dtdService.isConnected ? Icons.check_circle : Icons.lock,
                color: _dtdService.isConnected ? Colors.green : Colors.grey,
              ),
              onTap: _dtdService.isConnected
                  ? () async {
                      final success = await _dtdService.triggerHotReload();
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hot reload triggered')),
                        );
                      }
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Clear Debug Logs'),
              subtitle: const Text('Reset all debug output'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debug logs cleared')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfoSection() {
    final debugInfo = _dtdService.getDebugInfo();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Connection Status',
              debugInfo['connected'] ? 'Connected' : 'Disconnected',
            ),
            _buildInfoRow('DTD URI', debugInfo['uri'] ?? 'Not set'),
            _buildInfoRow('Last Updated', debugInfo['timestamp']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'DTD enables advanced debugging features for development',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
