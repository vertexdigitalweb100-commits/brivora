import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/project_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/models/project.dart'; // Added import for Project model
import '../../domain/models/task.dart';

class TasksProvider extends ChangeNotifier {
  final TaskRepository repository = TaskRepository();
  final ProjectRepository projectRepository = ProjectRepository();

  StreamSubscription<List<Task>>? _subscription;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all';

  List<Task> get tasks {
    if (_filter == 'all') return List.unmodifiable(_tasks);
    if (_filter == 'active') {
      return List.unmodifiable(
          _tasks.where((task) => task.status == TaskStatus.active));
    }
    if (_filter == 'inProgress') {
      return List.unmodifiable(
          _tasks.where((task) => task.status == TaskStatus.inProgress));
    }
    if (_filter == 'completed') {
      return List.unmodifiable(
          _tasks.where((task) => task.status == TaskStatus.completed));
    }
    return List.unmodifiable(_tasks);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void listenToProjectTasks(String projectId) {
    _subscription?.cancel();
    _subscription = repository.getProjectTasks(projectId).listen(
      (tasks) {
        _tasks = tasks;
        notifyListeners();
        _syncProjectProgress(projectId);
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void updateTasks(List<Task> tasks, String projectId) {
    _tasks = tasks;
    notifyListeners();
    _syncProjectProgress(projectId);
  }

  Future<Task> createTask(Task task) async {
    final createdTask = await repository.createTask(task);
    _tasks.insert(0, createdTask);
    notifyListeners();
    _syncProjectProgress(task.projectId);
    return createdTask;
  }

  Future<void> updateTask(Task task) async {
    await repository.updateTask(task);
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
      _syncProjectProgress(task.projectId);
    }
  }

  Future<void> deleteTask(String taskId, String projectId) async {
    await repository.deleteTask(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
    _syncProjectProgress(projectId);
  }

  Future<void> updateTaskStatus(
    Task task,
    TaskStatus status,
  ) async {
    final completedAt = status == TaskStatus.completed ? DateTime.now() : null;
    await repository.updateTaskStatus(task.id, status, completedAt);
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: status,
        completedAt: completedAt,
      );
      notifyListeners();
      _syncProjectProgress(task.projectId);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _syncProjectProgress(String projectId) async {
    if (_tasks.isEmpty) {
      await projectRepository.updateProjectProgress(projectId, 0.0);
      return;
    }

    final completedCount = _tasks.where((task) => task.status == TaskStatus.completed).length;
    final progress = completedCount / _tasks.length;

    await projectRepository.updateProjectProgress(projectId, progress);

    if (completedCount == _tasks.length && _tasks.isNotEmpty) {
      await projectRepository.updateProjectStatus(projectId, ProjectStatus.completed);
    }
  }
}
