import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaibal/gen/l10n/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_shell.dart';
import '../widgets/game_record_tile.dart';
import '../services/ogs_service.dart';
import '../services/match_history_service.dart';
import 'analysis_screen.dart';

/// Unified game history. Reads local records (AI / local 2P / synced OGS)
/// from [MatchHistoryService] and triggers an OGS refresh in the background
/// when the user is signed in. Survives offline mode and OGS API failures.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _refreshing = false;
  bool _didInitialRefresh = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Run once after first frame so we have access to providers.
    if (!_didInitialRefresh) {
      _didInitialRefresh = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshFromOgs());
    }
  }

  /// Pulls the user's latest games from OGS and upserts them into
  /// [MatchHistoryService]. No-op when not authenticated. Silently swallows
  /// network failures so the local view never breaks.
  Future<void> _refreshFromOgs() async {
    final ogs = context.read<OgsService>();
    if (!ogs.isAuthenticated || _refreshing) return;
    setState(() => _refreshing = true);
    try {
      final summaries = await ogs.fetchRecentGames(limit: 25);
      if (!mounted) return;
      final history = context.read<MatchHistoryService>();
      await history.addAll(summaries.map(MatchRecord.fromOgsSummary));
    } catch (_) {
      // Keep showing whatever we have locally.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch both services so the screen rebuilds on sign-in/out and when new
    // games are saved.
    context.watch<OgsService>();
    final history = context.watch<MatchHistoryService>();
    final records = history.records;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).gameHistory),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshing ? null : _refreshFromOgs,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFromOgs,
        child: records.isEmpty
            ? _buildEmpty(context)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: records.length,
                itemBuilder: (context, i) => GameRecordTile(
                  record: records[i],
                  onTap: () => _openRecord(records[i]),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        // History is a secondary screen; highlight Profile (closest tab).
        currentIndex: 3,
        onTap: (index) {
          appShellTabIndex.value = index;
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    // ListView so RefreshIndicator still works on empty state.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.history, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Center(
          child: Text(
            AppLocalizations.of(context).noRecentGames,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  void _openRecord(MatchRecord r) {
    // Game review is free — open the analysis screen directly.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalysisScreen(matchId: r.id)),
    );
  }
}
