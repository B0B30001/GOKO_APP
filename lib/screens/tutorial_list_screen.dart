import 'package:flutter/material.dart';
import '../gen/l10n/app_localizations.dart';
import '../models/tutorial.dart';
import '../services/content_service.dart';
import 'tutorial_screen.dart';

/// Lists all tutorials loaded from `assets/content/tutorials.json`.
/// Tap a row to open the step-by-step [TutorialScreen].
class TutorialListScreen extends StatelessWidget {
  const TutorialListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tutorialsTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Tutorial>>(
        future: ContentService.loadTutorials(
          languageCode: Localizations.localeOf(context).languageCode,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).tutorialsLoadError(snapshot.error.toString()),
                ),
              ),
            );
          }
          final tutorials = snapshot.data ?? const <Tutorial>[];
          if (tutorials.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context).noTutorialsYet),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: tutorials.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final t = tutorials[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(
                      _iconFor(t.category),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    t.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(t.summary),
                  ),
                  trailing: Text(
                    '${t.steps.length} steps',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TutorialScreen(tutorial: t),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'fundamentals':
        return Icons.menu_book;
      case 'rules':
        return Icons.gavel;
      case 'life-death':
        return Icons.psychology;
      default:
        return Icons.school;
    }
  }
}
