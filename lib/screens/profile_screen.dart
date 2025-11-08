import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreMenu(context),
                tooltip: 'More',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Player Name'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/200', // Placeholder
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsCard(context),
                _buildRecentGames(context),
                _buildAchievements(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            Navigator.pushReplacementNamed(
              context,
              index == 0 ? '/home' : '/learn',
            );
          }
        },
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to help
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to about
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Rating', '1500'),
                _buildStatItem(context, 'Games', '42'),
                _buildStatItem(context, 'Win Rate', '65%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildRecentGames(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Games',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (var i = 0; i < 3; i++)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: i % 2 == 0 ? Colors.green : Colors.red,
                child: Icon(
                  i % 2 == 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                ),
              ),
              title: Text('vs Player ${i + 1}'),
              subtitle: Text('${19 - i * 4}×${19 - i * 4} board'),
              trailing: Text(
                i % 2 == 0 ? '+7.5' : '-3.5',
                style: TextStyle(
                  color: i % 2 == 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: const EdgeInsets.all(16),
            children: [
              _buildAchievementIcon(Icons.star, 'First Win'),
              _buildAchievementIcon(Icons.trending_up, '5 Win Streak'),
              _buildAchievementIcon(Icons.psychology, 'Territory Master'),
              _buildAchievementIcon(Icons.school, 'Learning Complete'),
              _buildAchievementIcon(Icons.emoji_events, 'Tournament Winner'),
              _buildAchievementIcon(Icons.lock, 'Hidden'),
              _buildAchievementIcon(Icons.lock, 'Hidden'),
              _buildAchievementIcon(Icons.lock, 'Hidden'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Icon(icon, color: Colors.grey[700]),
      ),
    );
  }
}
