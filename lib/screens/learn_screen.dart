import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/drill.dart';
import 'drill_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _currentStreak = 7;
  int _puzzleRating = 1420;
  int _solvedToday = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Go'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.emoji_events),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_currentStreak',
                      style: const TextStyle(fontSize: 8, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Show achievements
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDailyChallenge(context),
          const SizedBox(height: 16),
          _buildQuickStats(context),
          const SizedBox(height: 16),
          _buildQuickDrills(context),
          const SizedBox(height: 16),
          _buildRecommendedPath(context),
          const SizedBox(height: 16),
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

  Widget _buildDailyChallenge(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to daily challenge
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Daily Challenge coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Challenge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fresh puzzle every day • ${_solvedToday}/3 solved today',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.trending_up,
            label: 'Puzzle Rating',
            value: '$_puzzleRating',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department,
            label: 'Day Streak',
            value: '$_currentStreak',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle,
            label: 'Today',
            value: '$_solvedToday/3',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDrills(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Quick Drills',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // View all drills
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDrillChip(
                    context,
                    drill: DrillData.getDrillById('capture_rush'),
                  ),
                  const SizedBox(width: 8),
                  _buildDrillChip(
                    context,
                    drill: DrillData.getDrillById('life_death_sprint'),
                  ),
                  const SizedBox(width: 8),
                  _buildDrillChip(
                    context,
                    drill: DrillData.getDrillById('ko_master'),
                  ),
                  const SizedBox(width: 8),
                  _buildDrillChip(
                    context,
                    drill: DrillData.getDrillById('tesuji_blitz'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillChip(BuildContext context, {required Drill drill}) {
    final IconData icon;
    final Color color;

    switch (drill.type) {
      case DrillType.capture:
        icon = Icons.close;
        color = Colors.red;
        break;
      case DrillType.lifeAndDeath:
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case DrillType.ko:
        icon = Icons.loop;
        color = Colors.purple;
        break;
      case DrillType.tesuji:
        icon = Icons.auto_fix_high;
        color = Colors.teal;
        break;
      case DrillType.mixed:
        icon = Icons.shuffle;
        color = Colors.blue;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DrillScreen(drill: drill)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    drill.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              drill.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedPath(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Recommended for You',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Based on your current level, we recommend starting here:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _buildPathStep(
              context,
              number: 1,
              title: 'Captures',
              description: 'Master the basics of capturing stones',
              isActive: true,
              progress: 0.6,
            ),
            const SizedBox(height: 12),
            _buildPathStep(
              context,
              number: 2,
              title: 'Liberties',
              description: 'Understand group liberties',
              isActive: false,
              progress: 0.0,
            ),
            const SizedBox(height: 12),
            _buildPathStep(
              context,
              number: 3,
              title: 'Life & Death',
              description: 'Learn to make your groups live',
              isActive: false,
              progress: 0.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathStep(
    BuildContext context, {
    required int number,
    required String title,
    required String description,
    required bool isActive,
    required double progress,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/topic',
          arguments: {'title': title, 'description': description},
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (progress > 0) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isActive ? Icons.play_circle_filled : Icons.lock_outline,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
          ],
        ),
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
    final isComplete = progress >= 1.0;
    final inProgress = progress > 0 && progress < 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: inProgress ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: inProgress
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.green.withValues(alpha: 0.1)
                          : inProgress
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: isComplete
                          ? Colors.green
                          : inProgress
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isComplete)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            if (inProgress)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'IN PROGRESS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isComplete
                              ? [Colors.green, Colors.green.shade700]
                              : [
                                  Theme.of(context).primaryColor,
                                  Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: inProgress
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).round()}% Complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isComplete
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  if (isComplete)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+50 XP',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                ],
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
