import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(ProjectStatus) onStatusChange;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
  });

  Color _getStatusColor() {
    switch (project.status) {
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.planning:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.grey;
      case ProjectStatus.archived:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.coverImageUrl != null &&
                project.coverImageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: project.coverImageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const SizedBox(
                  height: 180,
                  child: Center(child: Icon(Icons.broken_image, size: 40)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (project.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                project.description,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),

                      PopupMenuButton<ProjectStatus>(
                        onSelected: onStatusChange,
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: ProjectStatus.active,
                            child: Text('Активный'),
                          ),
                          const PopupMenuItem(
                            value: ProjectStatus.planning,
                            child: Text('Планирование'),
                          ),
                          const PopupMenuItem(
                            value: ProjectStatus.completed,
                            child: Text('Завершен'),
                          ),
                          const PopupMenuItem(
                            value: ProjectStatus.archived,
                            child: Text('Архив'),
                          ),
                        ],
                        child: Chip(
                          label: Text(project.status.shortName),
                          backgroundColor: _getStatusColor().withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Прогресс',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(project.progress * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: project.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${project.members.length} участников',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Редактировать',
                            onPressed: onTap,
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Удалить',
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
