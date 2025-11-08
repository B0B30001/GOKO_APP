import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Go'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLevelHeader(context),
          const SizedBox(height: 12),
          _buildLevelSection(
            context,
            title: 'Novice',
            stars: 1,
            topics: const [
              _Topic('Rules & Basics', Icons.menu_book, 0.9),
              _Topic('Liberties', Icons.blur_circular, 0.7),
              _Topic('Captures', Icons.close, 0.6),
              _Topic('Ko Basics', Icons.loop, 0.3),
            ],
          ),
          const SizedBox(height: 24),
          _buildLevelSection(
            context,
            title: 'Intermediate',
            stars: 2,
            topics: const [
              _Topic('Shape', Icons.gesture, 0.4),
              _Topic('Sente & Gote', Icons.swap_horiz, 0.2),
              _Topic('Joseki Intro', Icons.grid_3x3, 0.1),
              _Topic('Life & Death', Icons.psychology, 0.25),
            ],
          ),
          const SizedBox(height: 24),
          _buildLevelSection(
            context,
            title: 'Advanced',
            stars: 3,
            topics: const [
              _Topic('Fuseki', Icons.dashboard_customize, 0.05),
              _Topic('Tesuji', Icons.auto_fix_high, 0.15),
              _Topic('Yose (Endgame)', Icons.flag_circle, 0.0),
              _Topic('Influence vs Territory', Icons.compare_arrows, 0.0),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            Navigator.pushReplacementNamed(
              context,
              index == 0 ? '/home' : '/profile',
            );
          }
        },
      ),
    );
  }

  Widget _buildLevelHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber[600]),
        const SizedBox(width: 8),
        Text(
          'Choose your level',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildLevelSection(
    BuildContext context, {
    required String title,
    required int stars,
    required List<_Topic> topics,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var i = 0; i < stars; i++)
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                if (stars < 3)
                  for (var i = 0; i < 3 - stars; i++)
                    Icon(Icons.star_border, color: Colors.amber[400], size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...topics.map(
              (t) => _LessonCard(
                title: t.title,
                description: _topicDescription(t.title),
                icon: t.icon,
                progress: t.progress,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/topic',
                    arguments: {
                      'title': t.title,
                      'description': _topicDescription(t.title),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _topicDescription(String title) {
    switch (title) {
      case 'Rules & Basics':
        return 'Learn the core rules and flow of Go';
      case 'Liberties':
        return 'Understand liberties and groups';
      case 'Captures':
        return 'How to capture stones effectively';
      case 'Ko Basics':
        return 'What is Ko and how it works';
      case 'Shape':
        return 'Good and bad shapes to know';
      case 'Sente & Gote':
        return 'Initiative and tempo concepts';
      case 'Joseki Intro':
        return 'Common corner patterns overview';
      case 'Life & Death':
        return 'Tactics to live or kill groups';
      case 'Fuseki':
        return 'Opening strategies and frameworks';
      case 'Tesuji':
        return 'Tactical techniques that win fights';
      case 'Yose (Endgame)':
        return 'Scoring points efficiently in yose';
      case 'Influence vs Territory':
        return 'Balancing influence and territory';
      default:
        return '';
    }
  }
}

class _LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final VoidCallback? onTap;

  const _LessonCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).round()}% Complete',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Topic {
  final String title;
  final IconData icon;
  final double progress;
  const _Topic(this.title, this.icon, this.progress);
}
