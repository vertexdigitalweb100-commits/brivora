import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme.dart';
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
      if (mounted) {
        context.read<ProjectsProvider>().listenToProjects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final firstName = displayName != null && displayName.isNotEmpty
        ? displayName.split(' ').first
        : 'пользователь';

    final projects = context.watch<ProjectsProvider>().projects;
    final projectIds = projects.map((project) => project.id).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Добро пожаловать 👋',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Привет, $firstName',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Вот что происходит с вашими проектами.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
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
        value: '${projects.length}',
        icon: Icons.folder_outlined,
        iconBackground: AppColors.primaryLight,
        iconColor: AppColors.primary,
      ),
    ];

    if (stats.total > 0) {
      cards.add(
        _StatCard(
          title: 'Задачи',
          value: '${stats.total}',
          icon: Icons.checklist_rounded,
          iconBackground: AppColors.warningLight,
          iconColor: AppColors.warning,
        ),
      );
    }

    if (stats.completed > 0) {
      cards.add(
        _StatCard(
          title: 'Выполнено',
          value: '${stats.completed}',
          icon: Icons.check_circle_outline_rounded,
          iconBackground: AppColors.successLight,
          iconColor: AppColors.success,
        ),
      );
    }

    if (stats.inProgress > 0) {
      cards.add(
        _StatCard(
          title: 'В процессе',
          value: '${stats.inProgress}',
          icon: Icons.schedule_rounded,
          iconBackground: AppColors.primaryLight,
          iconColor: AppColors.primary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Обзор', style: Theme.of(context).textTheme.titleLarge),
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
          itemBuilder: (_, index) => cards[index],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_rounded,
            title: 'Новый проект',
            subtitle: 'Создать',
            color: AppColors.primary,
            onTap: widget.onCreateProject,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.calculate_outlined,
            title: 'Калькуляторы',
            subtitle: 'Материалы',
            color: AppColors.primary,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionText != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionText),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 3),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
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
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
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
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
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
    final progress = project.progress.clamp(0.0, 1.0);
    final percentage = (progress * 100).round();
    final statusColor = _statusColor(project.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatUpdatedAt(project.updatedAt ?? project.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
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
                  color: statusColor.withOpacity(0.10),
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
              Text('Прогресс', style: Theme.of(context).textTheme.bodySmall),
              Text(
                '$percentage%',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.mutedBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.planning:
        return AppColors.warning;
      case ProjectStatus.archived:
        return AppColors.textSecondary;
      case ProjectStatus.active:
        return AppColors.primary;
    }
  }

  static String _formatUpdatedAt(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Обновлено только что';
    if (difference.inMinutes < 60) {
      return 'Обновлено ${difference.inMinutes} мин. назад';
    }
    if (difference.inHours < 24) {
      return 'Обновлено ${difference.inHours} ч. назад';
    }
    if (difference.inDays == 1) return 'Обновлено вчера';
    if (difference.inDays < 7) {
      return 'Обновлено ${difference.inDays} дн. назад';
    }

    return 'Обновлено ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
