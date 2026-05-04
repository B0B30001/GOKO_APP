import 'package:flutter/material.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/theme/go_theme.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final bool showCoordinates;
  final ValueChanged<bool> onCoordinatesChanged;
  final bool forceLightGame;
  final ValueChanged<bool> onForceLightGameChanged;
  final String boardThemeId;
  final ValueChanged<String> onBoardThemeChanged;
  final String backgroundThemeId;
  final ValueChanged<String> onBackgroundThemeChanged;

  const SettingsScreen({
    required this.isDark,
    required this.onThemeChanged,
    required this.showCoordinates,
    required this.onCoordinatesChanged,
    required this.forceLightGame,
    required this.onForceLightGameChanged,
    required this.boardThemeId,
    required this.onBoardThemeChanged,
    required this.backgroundThemeId,
    required this.onBackgroundThemeChanged,
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _showCoordinates = false;
  bool _forceLightGame = true;
  late String _boardThemeId;
  late String _backgroundThemeId;
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _showCoordinates = widget.showCoordinates;
    _forceLightGame = widget.forceLightGame;
    _boardThemeId = widget.boardThemeId;
    _backgroundThemeId = widget.backgroundThemeId;
    _isDark = widget.isDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          _buildSection('Appearance', [
            SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between light and dark themes'),
              value: _isDark,
              onChanged: (v) {
                setState(() => _isDark = v);
                widget.onThemeChanged(v);
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Board theme'),
            ),
            _buildBoardThemePicker(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Background theme'),
            ),
            _buildBackgroundThemePicker(),
          ]),
          _buildSection('General', [
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
          _buildSection('Game Settings', [
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
          ]),
          _buildSection('Notifications', [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Get notified about your games'),
              value: _notificationsEnabled,
              onChanged: (value) =>
                  setState(() => _notificationsEnabled = value),
            ),
          ]),
          _buildSection('Language', [
            ListTile(
              title: const Text('App Language'),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showLanguageDialog,
            ),
          ]),
          _buildSection('Account', [
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
          ]),
          _buildSection('About', [
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
          ]),
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

  Widget _buildBoardThemePicker() {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: BoardThemeId.all.map((id) {
          final theme = GoBoardTheme.byId(id);
          final selected = id == _boardThemeId;
          return _ThemeSwatch(
            label: _boardThemeLabel(id),
            selected: selected,
            primary: theme.boardColor,
            secondary: theme.lineColor,
            onTap: () {
              setState(() => _boardThemeId = id);
              widget.onBoardThemeChanged(id);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBackgroundThemePicker() {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: BackgroundThemeId.all.map((id) {
          final theme = GoBackgroundTheme.byId(id);
          final selected = id == _backgroundThemeId;
          return _ThemeSwatch(
            label: _backgroundThemeLabel(id),
            selected: selected,
            primary: theme.scaffoldColor,
            secondary: theme.gradient.last,
            onTap: () {
              setState(() => _backgroundThemeId = id);
              widget.onBackgroundThemeChanged(id);
            },
          );
        }).toList(),
      ),
    );
  }

  String _boardThemeLabel(String id) => switch (id) {
    BoardThemeId.classic => 'Classic',
    BoardThemeId.walnut => 'Walnut',
    BoardThemeId.slate => 'Slate',
    BoardThemeId.night => 'Night',
    _ => id,
  };

  String _backgroundThemeLabel(String id) => switch (id) {
    BackgroundThemeId.standard => 'Standard',
    BackgroundThemeId.minimal => 'Minimal',
    BackgroundThemeId.warm => 'Warm',
    BackgroundThemeId.cool => 'Cool',
    _ => id,
  };

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

class _ThemeSwatch extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final Color secondary;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.label,
    required this.selected,
    required this.primary,
    required this.secondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
