import 'package:flutter/material.dart';

import '../../domain/models/project.dart';
import '../widgets/project_details_appbar.dart';
import '../../../notes/presentation/screens/notes_screen.dart';

/// Экран с деталями проекта
class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProjectDetailsAppBar(project: project),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),

            const SizedBox(height: 24),

            _buildProjectSections(context),
          ],
        ),
      ),
    );
  }

  /// Основная информация проекта
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Название',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 16),

            Text(
              'Дата создания',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _formatDate(project.createdAt),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  /// Разделы проекта
  Widget _buildProjectSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Разделы проекта', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.note_alt),
            title: const Text('Заметки'),
            subtitle: const Text('Записи и важная информация проекта'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotesScreen(projectId: project.id),
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Фото'),
            subtitle: const Text('Фото проекта'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Калькуляторы'),
            subtitle: const Text('Расчёт материалов'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Файлы'),
            subtitle: const Text('Документы проекта'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          ),
        ),
      ],
    );
  }
}
