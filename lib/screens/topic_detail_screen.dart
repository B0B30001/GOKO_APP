import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import 'puzzle_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? 'Topic';
    final description = args?['description'] as String? ?? '';

    // Get puzzles for this topic
    final puzzles = PuzzleData.getPuzzlesForTopic(title);

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puzzles & Lessons',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (puzzles.isEmpty)
                      ...List.generate(
                        3,
                        (i) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text('${i + 1}')),
                          title: Text('Lesson ${i + 1}'),
                          subtitle: const Text('Coming soon'),
                          onTap: () {},
                        ),
                      )
                    else
                      ...puzzles.asMap().entries.map((entry) {
                        final i = entry.key;
                        final puzzle = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text('${i + 1}'),
                          ),
                          title: Text(puzzle.title),
                          subtitle: Text(
                            '${'⭐' * puzzle.difficulty} - ${puzzle.description}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PuzzleScreen(puzzle: puzzle),
                              ),
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: puzzles.isEmpty
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lessons coming soon')),
                        );
                      }
                    : () {
                        // Start first puzzle
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PuzzleScreen(puzzle: puzzles.first),
                          ),
                        );
                      },
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  puzzles.isEmpty ? 'Coming Soon' : 'Start First Puzzle',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
