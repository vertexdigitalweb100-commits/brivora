import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/projects_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/create_project_dialog.dart';
import '../../domain/models/project.dart';
import '../../../../core/routes/app_routes.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

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
      context.read<ProjectsProvider>().listenToProjects();
    });
  }

  @override
  void dispose() {
    context.read<ProjectsProvider>().stopListening();
    super.dispose();
  }

  void _openCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (_) => CreateProjectDialog(
        onCreateProject: (title, description) async {
          await context.read<ProjectsProvider>().createProject(
            title,
            description: description,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Проект "$title" создан')));
        },
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2563EB);
    const background = Color(0xFFF8FAFC);
    const textPrimary = Color(0xFF0F172A);
    const textSecondary = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Consumer<ProjectsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.projects.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: primary),
              );
            }

            if (provider.error != null && provider.projects.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        style: const TextStyle(color: Color(0xFFEF4444)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: provider.listenToProjects,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final counts = provider.getProjectCountByStatus();
            final projects = _visibleProjects(provider.projects);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final horizontalPadding = isMobile ? 16.0 : 28.0;

                return CustomScrollView(
                  slivers: [
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
                                    'Projects',
                                    style: TextStyle(
                                      fontSize: isMobile ? 28 : 32,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      letterSpacing: -0.7,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Manage your construction projects',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _openCreateProjectDialog,
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: Text(isMobile ? 'New' : 'New Project'),
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
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
                              'Showing ${projects.length} projects',
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 13,
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
                    if (projects.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.folder_open_rounded,
                                    color: primary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'No projects yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Create your first project and keep everything organized in one place.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: textSecondary),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: _openCreateProjectDialog,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Create Project'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
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

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search projects...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildFilterBar(Map<ProjectStatus, int> counts) {
    final items = <({String label, int count, ProjectStatus? status})>[
      (
        label: 'All',
        count: counts.values.fold(0, (a, b) => a + b),
        status: null,
      ),
      (
        label: 'Active',
        count: counts[ProjectStatus.active] ?? 0,
        status: ProjectStatus.active,
      ),
      (
        label: 'Planning',
        count: counts[ProjectStatus.planning] ?? 0,
        status: ProjectStatus.planning,
      ),
      (
        label: 'Completed',
        count: counts[ProjectStatus.completed] ?? 0,
        status: ProjectStatus.completed,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  setState(() => _selectedFilter = item.status);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.label} ${item.count}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF334155),
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

  Widget _buildSortButton() {
    return PopupMenuButton<_ProjectSort>(
      initialValue: _sort,
      onSelected: (value) => setState(() => _sort = value),
      itemBuilder: (context) => _ProjectSort.values
          .map(
            (value) => PopupMenuItem(
              value: value,
              child: Row(
                children: [
                  if (value == _sort)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.check_rounded, size: 18),
                    ),
                  Text(_sortLabel(value)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 17, color: Color(0xFF64748B)),
            const SizedBox(width: 7),
            Text(
              'Sort: ${_sortLabel(_sort)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
