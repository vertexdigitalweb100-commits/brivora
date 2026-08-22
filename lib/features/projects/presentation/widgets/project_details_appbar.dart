import 'package:flutter/material.dart';
import '../../domain/models/project.dart';

/// Пользовательский AppBar для экрана Project Details
///
/// Отображает:
/// - Кнопку "Назад"
/// - Название проекта
/// - Статус проекта в виде badge
class ProjectDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Project project;

  const ProjectDetailsAppBar({super.key, required this.project});

  /// Возвращает цвет badge в зависимости от статуса проекта
  Color _getStatusColor(BuildContext context, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.purple;
      case ProjectStatus.archived:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Назад',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            project.title,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2.0),
          Text(
            'Проект',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        // Статус проекта
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(context, project.status),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                project.status.shortName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
