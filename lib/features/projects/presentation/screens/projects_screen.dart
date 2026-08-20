import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/projects_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/create_project_dialog.dart';
import '../../domain/models/project.dart';
import '../../../../core/routes/app_routes.dart';

class ProjectsScreen extends StatefulWidget {
  /// Если true — после открытия экрана автоматически
  /// показывается окно создания проекта.
  final bool autoOpenCreateDialog;

  /// Вызывается после того, как автоматическое открытие
  /// было обработано.
  final VoidCallback? onAutoOpenHandled;

  const ProjectsScreen({
    super.key,
    this.autoOpenCreateDialog = false,
    this.onAutoOpenHandled,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

enum _ProjectSort { newest, oldest, progress, nameAsc, nameDesc }

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectStatus? _selectedFilter;

  _ProjectSort _sort = _ProjectSort.newest;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<ProjectsProvider>();

      provider.listenToProjects();

      if (widget.autoOpenCreateDialog) {
        _openCreateProjectDialog();

        widget.onAutoOpenHandled?.call();
      }
    });
  }

  @override
  void dispose() {
    context.read<ProjectsProvider>().stopListening();
    super.dispose();
  }

  // ============================================================
  // СОЗДАНИЕ ПРОЕКТА
  // ============================================================

  void _openCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return CreateProjectDialog(
          onCreateProject: (title, description) async {
            await context.read<ProjectsProvider>().createProject(
              title,
              description: description,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Проект «$title» создан')));
          },
        );
      },
    );
  }

  // ============================================================
  // ФИЛЬТРАЦИЯ + ПОИСК + СОРТИРОВКА
  // ============================================================

  List<Project> _visibleProjects(List<Project> source) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = source.where((project) {
      final matchesStatus =
          _selectedFilter == null || project.status == _selectedFilter;

      final matchesSearch =
          query.isEmpty ||
          project.title.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _ProjectSort.newest:
          return b.createdAt.compareTo(a.createdAt);

        case _ProjectSort.oldest:
          return a.createdAt.compareTo(b.createdAt);

        case _ProjectSort.progress:
          return b.progress.compareTo(a.progress);

        case _ProjectSort.nameAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());

        case _ProjectSort.nameDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      }
    });

    return filtered;
  }

  String _sortLabel(_ProjectSort sort) {
    switch (sort) {
      case _ProjectSort.newest:
        return 'Новые';

      case _ProjectSort.oldest:
        return 'Старые';

      case _ProjectSort.progress:
        return 'Прогресс';

      case _ProjectSort.nameAsc:
        return 'Название А–Я';

      case _ProjectSort.nameDesc:
        return 'Название Я–А';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<ProjectsProvider>(
          builder: (context, provider, _) {
            // --------------------------------------------------
            // ЗАГРУЗКА
            // --------------------------------------------------

            if (provider.isLoading && provider.projects.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            // --------------------------------------------------
            // ОШИБКА
            // --------------------------------------------------

            if (provider.error != null && provider.projects.isEmpty) {
              return _buildErrorState(provider.error!);
            }

            // --------------------------------------------------
            // ДАННЫЕ
            // --------------------------------------------------

            final counts = provider.getProjectCountByStatus();

            final projects = _visibleProjects(provider.projects);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;

                final horizontalPadding = isMobile ? 16.0 : 28.0;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ==================================================
                    // ЗАГОЛОВОК
                    // ==================================================
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isMobile ? 18 : 28,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Проекты',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontSize: isMobile ? 28 : 32,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.7,
                                        ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Управляйте строительными проектами',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            FilledButton.icon(
                              onPressed: _openCreateProjectDialog,
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: Text(isMobile ? 'Новый' : 'Новый проект'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 14 : 18,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==================================================
                    // ПОИСК + ФИЛЬТРЫ
                    // ==================================================
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: isMobile
                            ? Column(
                                children: [
                                  _buildSearchField(),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Expanded(child: _buildFilterBar(counts)),

                                      const SizedBox(width: 8),

                                      _buildSortButton(),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _buildSearchField()),

                                  const SizedBox(width: 16),

                                  _buildFilterBar(counts),

                                  const SizedBox(width: 10),

                                  _buildSortButton(),
                                ],
                              ),
                      ),
                    ),

                    // ==================================================
                    // КОЛИЧЕСТВО ПРОЕКТОВ
                    // ==================================================
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        10,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Text(
                              'Показано проектов: ${projects.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Spacer(),

                            if (_searchQuery.isNotEmpty ||
                                _selectedFilter != null)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedFilter = null;
                                  });
                                },
                                child: const Text('Сбросить'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ==================================================
                    // ПУСТОЕ СОСТОЯНИЕ
                    // ==================================================
                    if (projects.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    // ==================================================
                    // СПИСОК ПРОЕКТОВ
                    // ==================================================
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          28,
                        ),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final project = projects[index];

                            return ProjectCard(
                              project: project,

                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.projectDetails,
                                  arguments: project,
                                );
                              },

                              onDelete: () async {
                                await context
                                    .read<ProjectsProvider>()
                                    .deleteProject(project.id);
                              },

                              onStatusChange: (status) async {
                                await context
                                    .read<ProjectsProvider>()
                                    .updateProjectStatus(project.id, status);
                              },
                            );
                          }, childCount: projects.length),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 390,
                                mainAxisSpacing: 18,
                                crossAxisSpacing: 18,
                                mainAxisExtent: isMobile ? 455 : 430,
                              ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // СОСТОЯНИЕ ОШИБКИ
  // ============================================================

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),

            const SizedBox(height: 16),

            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.error),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: () {
                context.read<ProjectsProvider>().listenToProjects();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ПУСТОЕ СОСТОЯНИЕ
  // ============================================================

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final hasFilters = _searchQuery.isNotEmpty || _selectedFilter != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                color: colors.primary,
                size: 32,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              hasFilters ? 'Ничего не найдено' : 'Пока нет проектов',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              hasFilters
                  ? 'Попробуйте изменить параметры поиска или фильтра.'
                  : 'Создайте первый проект, чтобы начать работу.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            if (!hasFilters)
              FilledButton.icon(
                onPressed: _openCreateProjectDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Создать проект'),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ПОИСК
  // ============================================================

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: TextStyle(color: colors.onSurface),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: 'Поиск проектов...',

        hintStyle: TextStyle(color: colors.onSurfaceVariant),

        prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),

        filled: true,

        fillColor: colors.surface,

        contentPadding: const EdgeInsets.symmetric(vertical: 15),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
    );
  }

  // ============================================================
  // ФИЛЬТРЫ
  // ============================================================

  Widget _buildFilterBar(Map<ProjectStatus, int> counts) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final items = <({String label, int count, ProjectStatus? status})>[
      (
        label: 'Все',
        count: counts.values.fold(0, (a, b) => a + b),
        status: null,
      ),
      (
        label: 'Активные',
        count: counts[ProjectStatus.active] ?? 0,
        status: ProjectStatus.active,
      ),
      (
        label: 'Планирование',
        count: counts[ProjectStatus.planning] ?? 0,
        status: ProjectStatus.planning,
      ),
      (
        label: 'Завершённые',
        count: counts[ProjectStatus.completed] ?? 0,
        status: ProjectStatus.completed,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            final selected = _selectedFilter == item.status;

            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _selectedFilter = item.status;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.label} ${item.count}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // СОРТИРОВКА
  // ============================================================

  Widget _buildSortButton() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopupMenuButton<_ProjectSort>(
      initialValue: _sort,

      onSelected: (value) {
        setState(() {
          _sort = value;
        });
      },

      itemBuilder: (context) {
        return _ProjectSort.values.map((value) {
          return PopupMenuItem<_ProjectSort>(
            value: value,
            child: Row(
              children: [
                if (value == _sort)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                Text(_sortLabel(value)),
              ],
            ),
          );
        }).toList();
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 17, color: colors.onSurfaceVariant),

            const SizedBox(width: 7),

            Text(
              'Сортировка: ${_sortLabel(_sort)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(width: 4),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
