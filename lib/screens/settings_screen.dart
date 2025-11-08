import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final bool showCoordinates;
  final ValueChanged<bool> onCoordinatesChanged;
  final bool forceLightGame;
  final ValueChanged<bool> onForceLightGameChanged;

  const SettingsScreen({
    required this.isDark,
    required this.onThemeChanged,
    required this.showCoordinates,
    required this.onCoordinatesChanged,
    required this.forceLightGame,
    required this.onForceLightGameChanged,
    super.key,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _showCoordinates = false;
  bool _forceLightGame = true;

  @override
  void initState() {
    super.initState();
    _showCoordinates = widget.showCoordinates;
    _forceLightGame = widget.forceLightGame;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection(
            'General', [
            SwitchListTile(
              title: const Text('Show board coordinates'),
              value: _showCoordinates,
              onChanged: (v) {
                setState(() => _showCoordinates = v);
                widget.onCoordinatesChanged(v);
              },
            ),
            SwitchListTile(
              title: const Text('Light theme in game'),
              subtitle: const Text('Force light theme on the Game screen'),
              value: _forceLightGame,
              onChanged: (v) {
                setState(() => _forceLightGame = v);
                widget.onForceLightGameChanged(v);
              },
            ),
          ]),
          _buildSection(
            'Game Settings',
            [
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Play sounds during the game'),
                value: _soundEnabled,
                onChanged: (value) => setState(() => _soundEnabled = value),
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate on move'),
                value: _vibrationEnabled,
                onChanged: (value) => setState(() => _vibrationEnabled = value),
              ),
            ],
          ),
          _buildSection(
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Get notified about your games'),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
              ),
            ],
          ),
          _buildSection(
            'Language',
            [
              ListTile(
                title: const Text('App Language'),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showLanguageDialog,
              ),
            ],
          ),
          _buildSection(
            'Account',
            [
              ListTile(
                title: const Text('Edit Profile'),
                leading: const Icon(Icons.person_outline),
                onTap: () {
                  // TODO: Navigate to profile edit
                },
              ),
              ListTile(
                title: const Text('Change Password'),
                leading: const Icon(Icons.lock_outline),
                onTap: () {
                  // TODO: Navigate to password change
                },
              ),
            ],
          ),
          _buildSection(
            'About',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                onTap: () {
                  // TODO: Show terms
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Русский'),
            _buildLanguageOption('中文'),
            _buildLanguageOption('日本語'),
            _buildLanguageOption('한국어'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
    );
  }
}