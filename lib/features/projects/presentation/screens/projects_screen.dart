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

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectStatus? _selectedFilter;

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
      builder: (context) {
        return CreateProjectDialog(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Проекты')),
      body: Consumer<ProjectsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        provider.listenToProjects();
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          final projects = _selectedFilter == null
              ? provider.projects
              : provider.getProjectsByStatus(_selectedFilter!);

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Все'),
                      selected: _selectedFilter == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...ProjectStatus.values.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status.displayName),
                          selected: _selectedFilter == status,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = status;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Expanded(
                child: projects.isEmpty
                    ? const Center(child: Text('Нет проектов'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
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
                            onDelete: () {
                              context.read<ProjectsProvider>().deleteProject(
                                project.id,
                              );
                            },
                            onStatusChange: (status) async {
                              await context
                                  .read<ProjectsProvider>()
                                  .updateProjectStatus(project.id, status);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
