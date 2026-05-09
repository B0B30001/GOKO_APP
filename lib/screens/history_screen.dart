import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/ogs_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ogs = Provider.of<OgsService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: FutureBuilder<List<GameSummary>>(
        future: ogs.fetchRecentGames(limit: 25),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No recent games',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final g = items[index];
              return _GameHistoryCard(
                opponent: g.opponent,
                date: g.ended ?? DateTime.now(),
                result: g.didWin ? 'Win' : 'Loss',
                score: g.score.isNotEmpty ? g.score : g.result,
                boardSize: g.size,
                color: g.didWin ? Colors.green : Colors.red,
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        // History isn't a top-level tab; highlight Profile (closest match)
        // since History is reached via Profile in the nav.
        currentIndex: 3,
        onTap: (index) {
          final route = switch (index) {
            0 => '/home',
            1 => '/learn',
            2 => '/puzzles',
            3 => '/profile',
            _ => '/home',
          };
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}

class _GameHistoryCard extends StatelessWidget {
  final String opponent;
  final DateTime date;
  final String result;
  final String score;
  final int boardSize;
  final Color color;

  const _GameHistoryCard({
    required this.opponent,
    required this.date,
    required this.result,
    required this.score,
    required this.boardSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Open game details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          opponent,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '$boardSize×$boardSize',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '$result ($score)',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
