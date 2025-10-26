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
          _buildSection(
            context,
            'Basics',
            [
              _LessonCard(
                title: 'Game Rules',
                description: 'Learn the basic rules of Go',
                icon: Icons.book,
                progress: 0.8,
              ),
              _LessonCard(
                title: 'Board Setup',
                description: 'Understanding the Go board',
                icon: Icons.grid_on,
                progress: 1.0,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Strategy',
            [
              _LessonCard(
                title: 'Capturing Stones',
                description: 'Master the art of capturing',
                icon: Icons.catching_pokemon,
                progress: 0.6,
              ),
              _LessonCard(
                title: 'Territory',
                description: 'Learn to build and defend territory',
                icon: Icons.map,
                progress: 0.3,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Advanced',
            [
              _LessonCard(
                title: 'Opening Theory',
                description: 'Study common opening patterns',
                icon: Icons.start,
                progress: 0.2,
              ),
              _LessonCard(
                title: 'Life and Death',
                description: 'Master life and death problems',
                icon: Icons.psychology,
                progress: 0.0,
              ),
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
              index == 0 ? '/home' :
              index == 2 ? '/history' :
              index == 3 ? '/profile' : '/more',
            );
          }
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double progress;

  const _LessonCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to lesson
        },
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