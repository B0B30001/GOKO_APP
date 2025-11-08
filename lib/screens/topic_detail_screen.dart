import 'package:flutter/material.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? 'Topic';
    final description = args?['description'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lessons', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...List.generate(3, (i) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text('${i + 1}')),
                          title: Text('Lesson ${i + 1}'),
                          subtitle: const Text('Coming soon'),
                          onTap: () {},
                        )),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Start first lesson or practice for this topic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lessons coming soon')),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
