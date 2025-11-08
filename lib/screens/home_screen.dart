// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import './game_board_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function onThemeToggle;

  const HomeScreen({required this.onThemeToggle, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  expandedHeight: 180,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                    title: const Text(''), // No title per request
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroBanner(context),
                        const SizedBox(height: 16),
                        Center(child: _buildPlayButton(context)),
                        const SizedBox(height: 20),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildDailyChallenge(context),
                        const SizedBox(height: 24),
                        _buildRecentHistory(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final secondary = Theme.of(context).colorScheme.secondary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary, secondary],
                ),
              ),
            ),
            // Decorative elements to hint a Go board theme
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Play • Learn • Improve',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sharpen your Go skills with quick games and lessons',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildPlayButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showGameModes(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.play_arrow_rounded, size: 28),
          SizedBox(width: 8),
          Text(
            'Play',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Practice',
                Icons.computer,
                () => _showBoardSize(context, isComputer: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                'Tutorial',
                Icons.school,
                () => Navigator.pushNamed(context, '/learn'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 6),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to daily challenge
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Challenge',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.stars, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Solve today\'s GO puzzle'),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: 0.3,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '30% Complete',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    final items = [
      _HistoryItem('vs Player A', '19×19', '+7.5', true, '2h ago'),
      _HistoryItem('vs Player B', '13×13', '-3.0', false, '1d ago'),
      _HistoryItem('vs Player C', '9×9', '+2.5', true, '3d ago'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Games', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final it = items[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: it.win ? Colors.green : Colors.red,
                  child: Icon(
                    it.win ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                  ),
                ),
                title: Text(it.title),
                subtitle: Text('${it.board} • ${it.timeAgo}'),
                trailing: Text(
                  it.delta,
                  style: TextStyle(
                    color: it.win ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/learn');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  void _showGameModes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Game Mode',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildModeButton(
              context,
              'vs Computer',
              Icons.computer,
              () => _showBoardSize(context, isComputer: true),
            ),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              'vs Friend (Local)',
              Icons.people,
              () => _showBoardSize(context, isComputer: false),
            ),
            const SizedBox(height: 16),
            _buildModeButton(context, 'vs Online', Icons.wifi, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showBoardSize(BuildContext context, {required bool isComputer}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Board Size',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildSizeButton(context, '9×9', 9),
            const SizedBox(height: 16),
            _buildSizeButton(context, '13×13', 13),
            const SizedBox(height: 16),
            _buildSizeButton(context, '19×19', 19),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeButton(BuildContext context, String label, int size) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context); // Close board size sheet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameBoardScreen(boardSize: size),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}

class _HistoryItem {
  final String title;
  final String board;
  final String delta;
  final bool win;
  final String timeAgo;

  _HistoryItem(this.title, this.board, this.delta, this.win, this.timeAgo);
}
