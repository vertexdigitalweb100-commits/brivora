import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/task_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/models/task.dart';
import '../../../photos/data/repositories/photo_repository.dart';
import '../../../photos/domain/models/photo.dart';
import '../../../estimates/data/repositories/estimate_repository.dart';
import '../../../estimates/domain/models/estimate_item.dart';

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

  static const primary = Color(0xFF2563EB);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  Color _statusColor() {
    switch (project.status) {
      case ProjectStatus.active:
        return const Color(0xFF22C55E);
      case ProjectStatus.planning:
        return const Color(0xFFF59E0B);
      case ProjectStatus.completed:
        return const Color(0xFF64748B);
      case ProjectStatus.archived:
        return const Color(0xFF94A3B8);
    }
  }

  String _statusLabel() {
    switch (project.status) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  String _formatMoney(double value) {
    if (value >= 1000000) {
      return '₸${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '₸${(value / 1000).toStringAsFixed(0)}K';
    }
    return '₸${value.round()}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = project.progress.clamp(0.0, 1.0);
    final statusColor = _statusColor();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0F172A),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (project.coverImageUrl != null &&
                        project.coverImageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: project.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ColoredBox(
                          color: Color(0xFFE2E8F0),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFE2E8F0),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: textSecondary,
                              size: 34,
                            ),
                          ),
                        ),
                      )
                    else
                      const ColoredBox(
                        color: Color(0xFFEFF6FF),
                        child: Center(
                          child: Icon(
                            Icons.business_rounded,
                            color: primary,
                            size: 42,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x260F172A),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _statusLabel(),
                              style: TextStyle(
                                color: statusColor == const Color(0xFF64748B)
                                    ? const Color(0xFF334155)
                                    : statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: PopupMenuButton<String>(
                        tooltip: 'Project actions',
                        onSelected: (value) {
                          switch (value) {
                            case 'active':
                              onStatusChange(ProjectStatus.active);
                              break;
                            case 'planning':
                              onStatusChange(ProjectStatus.planning);
                              break;
                            case 'completed':
                              onStatusChange(ProjectStatus.completed);
                              break;
                            case 'archived':
                              onStatusChange(ProjectStatus.archived);
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'active', child: Text('Active')),
                          PopupMenuItem(
                            value: 'planning',
                            child: Text('Planning'),
                          ),
                          PopupMenuItem(
                            value: 'completed',
                            child: Text('Completed'),
                          ),
                          PopupMenuItem(
                            value: 'archived',
                            child: Text('Archive'),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x260F172A),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.more_vert_rounded,
                            size: 20,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (project.description.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          project.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFEFF3F8),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Expanded(
                        child: StreamBuilder<List<Task>>(
                          stream: TaskRepository().getProjectTasks(project.id),
                          builder: (context, taskSnapshot) {
                            final tasks = taskSnapshot.data ?? const <Task>[];

                            return StreamBuilder<List<Photo>>(
                              stream: PhotoRepository().getProjectPhotos(
                                project.id,
                              ),
                              builder: (context, photoSnapshot) {
                                final photos =
                                    photoSnapshot.data ?? const <Photo>[];

                                return StreamBuilder<List<EstimateItem>>(
                                  stream: EstimateRepository()
                                      .getProjectEstimatesStream(project.id),
                                  builder: (context, estimateSnapshot) {
                                    final estimateItems =
                                        estimateSnapshot.data ??
                                        const <EstimateItem>[];

                                    final completedTasks = tasks
                                        .where(
                                          (task) =>
                                              task.status ==
                                              TaskStatus.completed,
                                        )
                                        .length;

                                    final totalEstimate = estimateItems
                                        .fold<double>(
                                          0,
                                          (sum, item) => sum + item.totalPrice,
                                        );

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _Stat(
                                            icon: Icons.check_box_outlined,
                                            value:
                                                '$completedTasks/${tasks.length}',
                                            label: 'Tasks',
                                          ),
                                        ),
                                        const _Divider(),
                                        Expanded(
                                          child: _Stat(
                                            icon: Icons.image_outlined,
                                            value: '${photos.length}',
                                            label: 'Photos',
                                          ),
                                        ),
                                        const _Divider(),
                                        Expanded(
                                          child: _Stat(
                                            icon: Icons.payments_outlined,
                                            value: _formatMoney(totalEstimate),
                                            label: 'Estimate',
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: const Color(0xFFE2E8F0));
  }
}
