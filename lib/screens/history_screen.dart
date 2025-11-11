import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: 10, // Временно для демонстрации
        itemBuilder: (context, index) {
          final isWin = index % 2 == 0;
          return _GameHistoryCard(
            opponent: 'Player ${index + 1}',
            date: DateTime.now().subtract(Duration(days: index)),
            result: isWin ? 'Win' : 'Loss',
            score: isWin ? '+7.5' : '-3.5',
            boardSize: index % 3 == 0 ? 19 : (index % 3 == 1 ? 13 : 9),
            color: isWin ? Colors.green : Colors.red,
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            Navigator.pushReplacementNamed(
              context,
              index == 0
                  ? '/home'
                  : index == 1
                  ? '/learn'
                  : '/profile',
            );
          }
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
