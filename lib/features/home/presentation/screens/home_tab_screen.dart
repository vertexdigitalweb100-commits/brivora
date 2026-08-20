import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../projects/data/repositories/task_repository.dart';
import '../../../projects/domain/models/project.dart';
import '../../../projects/presentation/providers/projects_provider.dart';

class HomeTabScreen extends StatefulWidget {
  final VoidCallback onCreateProject;
  final VoidCallback onViewAllProjects;

  const HomeTabScreen({
    super.key,
    required this.onCreateProject,
    required this.onViewAllProjects,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final TaskRepository _taskRepository = TaskRepository();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<ProjectsProvider>();
      provider.listenToProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.trim();

    final firstName = displayName != null && displayName.isNotEmpty
        ? displayName.split(' ').first
        : 'пользователь';

    final projectsProvider = context.watch<ProjectsProvider>();
    final projects = projectsProvider.projects;

    final projectIds = projects
        .map((project) => project.id)
        .where((id) => id.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context, firstName),

                  const SizedBox(height: 28),

                  FutureBuilder<TaskStats>(
                    future: _taskRepository.getTaskStatsForProjects(projectIds),
                    builder: (context, snapshot) {
                      final stats = snapshot.data ?? TaskStats.empty;

                      return _buildOverview(context, projects, stats);
                    },
                  ),

                  const SizedBox(height: 28),

                  _buildSectionHeader(context, title: 'Быстрые действия'),

                  const SizedBox(height: 12),

                  _buildQuickActions(context),

                  const SizedBox(height: 28),

                  _buildRecentProjectsSection(context, projects),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Добро пожаловать 👋',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Привет, $firstName',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Вот что происходит с вашими проектами.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: colors.onPrimaryContainer,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildOverview(
    BuildContext context,
    List<Project> projects,
    TaskStats stats,
  ) {
    final theme = Theme.of(context);

    if (projects.isEmpty) {
      return _buildEmptyCard(
        context,
        icon: Icons.folder_open_outlined,
        title: 'Нет созданных проектов',
        subtitle: 'Создайте первый проект, чтобы начать работу.',
      );
    }

    final cards = <Widget>[
      _StatCard(
        title: 'Проекты',
        value: projects.length.toString(),
        icon: Icons.folder_outlined,
        iconType: _StatCardColor.primary,
      ),

      _StatCard(
        title: 'Задачи',
        value: stats.total.toString(),
        icon: Icons.checklist_rounded,
        iconType: _StatCardColor.warning,
      ),

      _StatCard(
        title: 'Выполнено',
        value: stats.completed.toString(),
        icon: Icons.check_circle_outline_rounded,
        iconType: _StatCardColor.success,
      ),

      _StatCard(
        title: 'В процессе',
        value: stats.inProgress.toString(),
        icon: Icons.schedule_rounded,
        iconType: _StatCardColor.primary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Обзор',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            return cards[index];
          },
        ),
      ],
    );
  }

  Widget _buildRecentProjectsSection(
    BuildContext context,
    List<Project> projects,
  ) {
    if (projects.isEmpty) {
      return _buildEmptyCard(
        context,
        icon: Icons.history_rounded,
        title: 'Пока нет недавних проектов',
        subtitle: 'Здесь появятся проекты, с которыми вы работаете.',
      );
    }

    final recentProjects = projects.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Недавние проекты',
          actionText: 'Все',
          onActionTap: widget.onViewAllProjects,
        ),

        const SizedBox(height: 12),

        ...recentProjects.map(
          (project) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProjectCard(project: project),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: colors.onPrimaryContainer),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_rounded,
            title: 'Новый проект',
            subtitle: 'Создать',
            color: colors.primary,
            onTap: widget.onCreateProject,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _QuickActionCard(
            icon: Icons.calculate_outlined,
            title: 'Калькуляторы',
            subtitle: 'Материалы',
            color: colors.primary,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.calculators);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (actionText != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colors.primary,
            ),
            child: Text(actionText),
          ),
      ],
    );
  }
}

enum _StatCardColor { primary, warning, success }

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final _StatCardColor iconType;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    late Color iconColor;

    switch (iconType) {
      case _StatCardColor.primary:
        iconColor = colors.primary;
        break;

      case _StatCardColor.warning:
        iconColor = const Color(0xFFF59E0B);
        break;

      case _StatCardColor.success:
        iconColor = const Color(0xFF22C55E);
        break;
    }

    final iconBackground = iconColor.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.18 : 0.10,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),

          const SizedBox(height: 16),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // ВАЖНО:
    // clamp() возвращает num,
    // поэтому явно преобразуем обратно в double.
    final double progress = project.progress.clamp(0.0, 1.0).toDouble();

    final int percentage = (progress * 100).round();

    final statusColor = _statusColor(project.status, colors);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
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
                      project.title.isEmpty ? 'Без названия' : project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _formatUpdatedAt(project.updatedAt ?? project.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  project.status.shortName,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Прогресс',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              Text(
                '$percentage%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(ProjectStatus status, ColorScheme colors) {
    switch (status) {
      case ProjectStatus.completed:
        return const Color(0xFF22C55E);

      case ProjectStatus.planning:
        return const Color(0xFFF59E0B);

      case ProjectStatus.archived:
        return colors.onSurfaceVariant;

      case ProjectStatus.active:
        return colors.primary;
    }
  }

  static String _formatUpdatedAt(DateTime date) {
    final now = DateTime.now();

    final difference = now.difference(date);

    if (difference.isNegative) {
      return 'Обновлено недавно';
    }

    if (difference.inMinutes < 1) {
      return 'Обновлено только что';
    }

    if (difference.inMinutes < 60) {
      return 'Обновлено ${difference.inMinutes} мин. назад';
    }

    if (difference.inHours < 24) {
      return 'Обновлено ${difference.inHours} ч. назад';
    }

    if (difference.inDays == 1) {
      return 'Обновлено вчера';
    }

    if (difference.inDays < 7) {
      return 'Обновлено ${difference.inDays} дн. назад';
    }

    return 'Обновлено '
        '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
