import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/project_repository.dart';
import '../../domain/models/project.dart';

class ProjectsProvider extends ChangeNotifier {
  final ProjectRepository repository = ProjectRepository();

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<Project>>? _projectsSubscription;

  bool _isListening = false;

  /// Все проекты пользователя.
  List<Project> get projects => List.unmodifiable(_projects);

  /// Состояние загрузки.
  bool get isLoading => _isLoading;

  /// Ошибка.
  String? get error => _error;

  /// Запускает realtime-синхронизацию проектов с Firestore.
  void listenToProjects() {
    if (_isListening) return;

    _isListening = true;
    _isLoading = true;
    _error = null;

    notifyListeners();

    _projectsSubscription = repository.getUserProjectsStream().listen(
      (projects) {
        _projects = projects;
        _isLoading = false;
        _error = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _error = 'Ошибка при загрузке проектов: $error';

        notifyListeners();
      },
    );
  }

  /// Останавливает realtime-синхронизацию.
  Future<void> stopListening() async {
    await _projectsSubscription?.cancel();

    _projectsSubscription = null;
    _isListening = false;
  }

  /// Однократная загрузка проектов.
  ///
  /// Оставляем метод, чтобы старые места приложения,
  /// которые его вызывают, не ломались.
  Future<void> loadProjects() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final projects = await repository.getUserProjects();

      _projects = projects;
      _error = null;
    } catch (e) {
      _error = 'Ошибка при загрузке проектов: $e';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  /// Создание проекта.
  Future<void> createProject(String title, {String description = ''}) async {
    try {
      _error = null;

      final project = await repository.createProject(
        title: title,
        description: description,
      );

      // Если realtime listener уже работает,
      // Firestore сам пришлёт новый проект.
      //
      // Поэтому здесь вручную список не меняем,
      // чтобы не получить дубликат.
      if (!_isListening) {
        _projects.insert(0, project);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка при создании проекта: $e';

      notifyListeners();

      rethrow;
    }
  }

  /// Удаление проекта.
  Future<void> deleteProject(String projectId) async {
    try {
      _error = null;

      await repository.deleteProject(projectId);

      // При активном listener Firestore сам обновит список.
      if (!_isListening) {
        _projects.removeWhere((project) => project.id == projectId);

        notifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка при удалении проекта: $e';

      notifyListeners();

      rethrow;
    }
  }

  /// Получить проекты по статусу.
  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }

  /// Получить проект по ID.
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Изменить статус проекта.
  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    try {
      _error = null;

      await repository.updateProjectStatus(projectId, status);

      // При realtime listener Firestore сам отправит
      // обновлённый проект.
      if (!_isListening) {
        final index = _projects.indexWhere(
          (project) => project.id == projectId,
        );

        if (index != -1) {
          _projects[index] = _projects[index].copyWith(status: status);

          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Ошибка при изменении статуса: $e';

      notifyListeners();

      rethrow;
    }
  }

  /// Изменить прогресс проекта.
  Future<void> updateProjectProgress(String projectId, double progress) async {
    final normalizedProgress = progress.clamp(0.0, 1.0);

    try {
      _error = null;

      await repository.updateProjectProgress(projectId, normalizedProgress);

      // При realtime listener Firestore сам обновит
      // проект в списке.
      if (!_isListening) {
        final index = _projects.indexWhere(
          (project) => project.id == projectId,
        );

        if (index != -1) {
          _projects[index] = _projects[index].copyWith(
            progress: normalizedProgress,
          );

          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Ошибка при обновлении прогресса: $e';

      notifyListeners();

      rethrow;
    }
  }

  /// Количество проектов по статусам.
  Map<ProjectStatus, int> getProjectCountByStatus() {
    return {
      ProjectStatus.active: _projects
          .where((project) => project.status == ProjectStatus.active)
          .length,
      ProjectStatus.planning: _projects
          .where((project) => project.status == ProjectStatus.planning)
          .length,
      ProjectStatus.completed: _projects
          .where((project) => project.status == ProjectStatus.completed)
          .length,
      ProjectStatus.archived: _projects
          .where((project) => project.status == ProjectStatus.archived)
          .length,
    };
  }

  @override
  void dispose() {
    _projectsSubscription?.cancel();
    super.dispose();
  }
}
