import 'package:flutter/material.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import 'package:zaibal/models/app_settings.dart';
import 'package:zaibal/theme/go_theme.dart';
import 'package:zaibal/widgets/goko_logo.dart';

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
  final String themePresetId;
  final ValueChanged<String> onThemePresetChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;

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
    required this.themePresetId,
    required this.onThemePresetChanged,
    required this.languageCode,
    required this.onLanguageChanged,
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// Maps the display name shown in the picker to a BCP-47 language code.
const _kLanguageOptions = <String, String>{
  'English': 'en',
  'Русский': 'ru',
  '中文': 'zh',
  '日本語': 'ja',
  '한국어': 'ko',
};

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  late String _languageCode;
  bool _showCoordinates = false;
  bool _forceLightGame = true;
  late String _boardThemeId;
  late String _backgroundThemeId;
  late String _themePresetId;
  late bool _isDark;

  String get _selectedLanguage => _kLanguageOptions.entries
      .firstWhere(
        (e) => e.value == _languageCode,
        orElse: () => const MapEntry('English', 'en'),
      )
      .key;

  @override
  void initState() {
    super.initState();
    _showCoordinates = widget.showCoordinates;
    _forceLightGame = widget.forceLightGame;
    _boardThemeId = widget.boardThemeId;
    _backgroundThemeId = widget.backgroundThemeId;
    _themePresetId = widget.themePresetId;
    _isDark = widget.isDark;
    _languageCode = widget.languageCode;
    _soundEnabled = AppSettings.soundEnabled;
    _vibrationEnabled = AppSettings.hapticsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GokoLogo(size: 22),
            const SizedBox(width: 8),
            Text(l.settings),
          ],
        ),
      ),
      body: ListView(
        children: [
          _buildSection(l.appearance, [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(l.themeLabel),
            ),
            _buildThemePresetPicker(),
            SwitchListTile(
              title: Text(l.darkMode),
              subtitle: Text(l.darkModeSubtitle),
              value: _isDark,
              onChanged: (v) {
                setState(() => _isDark = v);
                widget.onThemeChanged(v);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l.boardThemeLabel),
            ),
            _MiniBoardPreview(theme: GoBoardTheme.byId(_boardThemeId)),
            _buildBoardThemePicker(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l.backgroundThemeLabel),
            ),
            _buildBackgroundThemePicker(),
          ]),
          _buildSection(l.general, [
            SwitchListTile(
              title: Text(l.showCoordinates),
              value: _showCoordinates,
              onChanged: (v) {
                setState(() => _showCoordinates = v);
                widget.onCoordinatesChanged(v);
              },
            ),
            SwitchListTile(
              title: Text(l.lightThemeInGame),
              subtitle: Text(l.lightThemeInGameSubtitle),
              value: _forceLightGame,
              onChanged: (v) {
                setState(() => _forceLightGame = v);
                widget.onForceLightGameChanged(v);
              },
            ),
          ]),
          _buildSection(l.gameSettings, [
            SwitchListTile(
              title: Text(l.soundEffects),
              subtitle: Text(l.soundEffectsSubtitle),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
                AppSettings.soundEnabled = value;
                AppSettings.save();
              },
            ),
            SwitchListTile(
              title: Text(l.vibration),
              subtitle: Text(l.vibrationSubtitle),
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() => _vibrationEnabled = value);
                AppSettings.hapticsEnabled = value;
                AppSettings.save();
              },
            ),
          ]),
          _buildSection(l.language, [
            ListTile(
              title: Text(l.appLanguage),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showLanguageDialog,
            ),
          ]),
          _buildSection(l.about, [
            ListTile(title: Text(l.version), subtitle: const Text('1.0.0')),
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
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.appLanguage),
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

  Widget _buildThemePresetPicker() {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: ThemePresetIds.all.map((id) {
          final preset = ThemePresetIds.toEnum(id);
          final theme = GoTheme.fromPreset(preset);
          final selected = id == _themePresetId;
          return _ThemeSwatch(
            label: _themePresetLabel(l, preset),
            selected: selected,
            primary: theme.scaffoldBackgroundColor,
            secondary: theme.colorScheme.primary,
            onTap: () {
              setState(() => _themePresetId = id);
              widget.onThemePresetChanged(id);
            },
          );
        }).toList(),
      ),
    );
  }

  String _themePresetLabel(AppLocalizations l, ThemePreset p) => switch (p) {
    ThemePreset.darkBlue => l.themeDarkBlue,
    ThemePreset.oledBlack => l.themeOledBlack,
    ThemePreset.classicWood => l.themeClassicWood,
    ThemePreset.lightMode => l.themeLightMode,
    ThemePreset.halloween => l.themeHalloween,
    ThemePreset.winter => l.themeWinter,
    ThemePreset.forest => l.themeForest,
  };

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

  String _boardThemeLabel(String id) {
    final l = AppLocalizations.of(context);
    return switch (id) {
      BoardThemeId.classic => l.boardClassic,
      BoardThemeId.walnut => l.boardWalnut,
      BoardThemeId.slate => l.boardSlate,
      BoardThemeId.night => l.boardNight,
      _ => id,
    };
  }

  String _backgroundThemeLabel(String id) {
    final l = AppLocalizations.of(context);
    return switch (id) {
      BackgroundThemeId.standard => l.bgStandard,
      BackgroundThemeId.minimal => l.bgMinimal,
      BackgroundThemeId.warm => l.bgWarm,
      BackgroundThemeId.cool => l.bgCool,
      _ => id,
    };
  }

  Widget _buildLanguageOption(String language) {
    final code = _kLanguageOptions[language] ?? 'en';
    final selected = _languageCode == code;
    return ListTile(
      title: Text(language),
      trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        setState(() => _languageCode = code);
        widget.onLanguageChanged(code);
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

// ── Live board theme preview ───────────────────────────────────────────────

class _MiniBoardPreview extends StatelessWidget {
  final GoBoardTheme theme;

  const _MiniBoardPreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 180,
          child: CustomPaint(painter: _MiniBoardPainter(theme: theme)),
        ),
      ),
    );
  }
}

class _MiniBoardPainter extends CustomPainter {
  final GoBoardTheme theme;

  const _MiniBoardPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Board background
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.boardColor);

    const gridLines = 9;
    final margin = size.width * 0.08;
    final step = (size.width - margin * 2) / (gridLines - 1);

    final linePaint = Paint()
      ..color = theme.lineColor.withValues(alpha: 0.6)
      ..strokeWidth = 0.8;

    // Grid lines
    for (var i = 0; i < gridLines; i++) {
      final x = margin + i * step;
      final y = margin + i * step;
      canvas.drawLine(
        Offset(x, margin),
        Offset(x, size.height - margin),
        linePaint,
      );
      canvas.drawLine(
        Offset(margin, y),
        Offset(size.width - margin, y),
        linePaint,
      );
    }

    // Hoshi (star points) at tengen + 4 corners
    final hoshiPaint = Paint()..color = theme.lineColor.withValues(alpha: 0.7);
    for (final (ix, iy) in [(2, 2), (6, 2), (4, 4), (2, 6), (6, 6)]) {
      canvas.drawCircle(
        Offset(margin + ix * step, margin + iy * step),
        3,
        hoshiPaint,
      );
    }

    // Example stones
    final blackPaint = Paint()..color = theme.blackStoneColor;
    final whitePaint = Paint()..color = theme.whiteStoneColor;
    final borderPaint = Paint()
      ..color = theme.lineColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final r = step * 0.44;

    void stone(int gx, int gy, Paint fill) {
      final center = Offset(margin + gx * step, margin + gy * step);
      canvas.drawCircle(center, r, fill);
      if (fill == whitePaint) canvas.drawCircle(center, r, borderPaint);
    }

    stone(3, 3, blackPaint);
    stone(4, 3, whitePaint);
    stone(3, 4, whitePaint);
    stone(4, 4, blackPaint);
    stone(5, 3, blackPaint);
    stone(5, 4, whitePaint);
  }

  @override
  bool shouldRepaint(_MiniBoardPainter old) => old.theme != theme;
}
