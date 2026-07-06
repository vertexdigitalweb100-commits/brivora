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
    // Загружаем проекты при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsProvider>().loadProjects();
    });
  }

  void _openCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(
        onCreateProject: (title, description) async {
          try {
            await context.read<ProjectsProvider>().createProject(
              title,
              description: description,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Проект "$title" создан'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteProject(String projectId, String projectTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить проект?'),
        content: Text('Вы уверены, что хотите удалить проект "$projectTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<ProjectsProvider>().deleteProject(projectId);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Проект удален'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Проекты'),
        elevation: 0,
      ),
      body: Consumer<ProjectsProvider>(
        builder: (context, projectsProvider, _) {
          if (projectsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final projects = _selectedFilter == null
              ? projectsProvider.projects
              : projectsProvider.getProjectsByStatus(_selectedFilter!);

          return Column(
            children: [
              // Фильтры
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Кнопка "Все"
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
                    // Фильтры по статусам
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

              // Список проектов
              Expanded(
                child: projects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == null
                                  ? 'Нет проектов'
                                  : 'Нет проектов с статусом "${_selectedFilter!.displayName}"',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нажмите + чтобы создать новый',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return ProjectCard(
                            project: project,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.projectDetails,
                                arguments: project,
                              );
                            },
                            onDelete: () {
                              _deleteProject(project.id, project.title);
                            },
                            onStatusChange: (newStatus) async {
                              try {
                                await context.read<ProjectsProvider>().updateProjectStatus(
                                  project.id,
                                  newStatus,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Статус изменен на "${newStatus.shortName}"',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ошибка: $e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
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
        tooltip: 'Создать проект',
        child: const Icon(Icons.add),
      ),
    );
  }
}
