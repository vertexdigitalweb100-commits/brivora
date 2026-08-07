import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/project.dart';
import '../../domain/models/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/project_details_appbar.dart';
import '../../../notes/presentation/screens/notes_screen.dart';
import '../../../photos/presentation/screens/photos_screen.dart';

/// Экран с деталями проекта
class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  Project get project => widget.project;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().listenToProjectTasks(widget.project.id);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

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
    return Scaffold(
      appBar: ProjectDetailsAppBar(project: project),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(context),
        label: const Text('Добавить задачу'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),

            const SizedBox(height: 20),

            _buildTaskSection(context),

            const SizedBox(height: 20),

            _buildProjectSections(context),
          ],
        ),
      ),
    );
  }

  /// Основная информация проекта
  Widget _buildInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasCover = project.coverImageUrl != null && project.coverImageUrl!.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 220,
              child: hasCover
                  ? Image.network(
                      project.coverImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: colorScheme.surfaceVariant,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 56,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: colorScheme.surfaceVariant,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(context, project.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        project.status.shortName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: _getStatusColor(context, project.status),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.description.isNotEmpty ? project.description : 'Описание отсутствует',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Прогресс',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '${(project.progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: project.progress.clamp(0.0, 1.0),
                    minHeight: 10,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(project.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final tasks = tasksProvider.tasks;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Задачи', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(context, 'all', 'Все'),
                _buildFilterChip(context, 'active', 'Активные'),
                _buildFilterChip(context, 'inProgress', 'В процессе'),
                _buildFilterChip(context, 'completed', 'Выполненные'),
              ],
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Нет задач для этого проекта',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            else
              Column(
                children: tasks.map((task) => _buildTaskCard(context, task)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label) {
    final tasksProvider = context.read<TasksProvider>();
    final selected = tasksProvider.filter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => tasksProvider.setFilter(value),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final tasksProvider = context.read<TasksProvider>();
    final statusColor = task.status == TaskStatus.completed ? Colors.green : Colors.blue;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: InkWell(
          onTap: () {
            final nextStatus = task.status == TaskStatus.completed
                ? TaskStatus.active
                : TaskStatus.completed;
            tasksProvider.updateTaskStatus(task, nextStatus);
          },
          borderRadius: BorderRadius.circular(24),
          child: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.12),
            child: Icon(
              task.status == TaskStatus.completed ? Icons.check : Icons.radio_button_unchecked,
              color: statusColor,
            ),
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              task.description.isNotEmpty ? task.description : 'Описание отсутствует',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(task.priority.displayName),
                ),
                const SizedBox(width: 10),
                Text(
                  task.status.displayName,
                  style: TextStyle(color: statusColor),
                ),
                if (task.deadline != null) ...[
                  const SizedBox(width: 10),
                  Text('до ${_formatDate(task.deadline!)}'),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            tasksProvider.deleteTask(task.id, project.id);
          },
        ),
      ),
    );
  }

  Future<void> _showCreateTaskDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskPriority priority = TaskPriority.normal;
    DateTime? deadline;
    bool canSave = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Новая задача'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      onChanged: (value) {
                        setState(() => canSave = value.trim().isNotEmpty);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Название',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskPriority>(
                      value: priority,
                      items: TaskPriority.values.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value.displayName),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Приоритет',
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => priority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deadline != null
                                ? 'Срок: ${_formatDate(deadline!)}'
                                : 'Срок не выбран',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => deadline = picked);
                            }
                          },
                          child: const Text('Выбрать'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: canSave
                      ? () async {
                          final task = Task(
                            id: '',
                            projectId: project.id,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            status: TaskStatus.active,
                            priority: priority,
                            createdAt: DateTime.now(),
                            deadline: deadline,
                            completedAt: null,
                          );

                          try {
                            await context.read<TasksProvider>().createTask(task);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Не удалось сохранить задачу: $e')),
                            );
                          }
                        }
                      : null,
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhotosScreen(projectId: project.id),
                ),
              );
            },
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
