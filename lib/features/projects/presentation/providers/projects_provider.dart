import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/project_repository.dart';
import '../../domain/models/project.dart';

class ProjectsProvider extends ChangeNotifier {
  final ProjectRepository repository = ProjectRepository();

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<Project>>? _projectsSubscription;

  bool _isListening = false;

  List<Project> get projects => List.unmodifiable(_projects);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isListening => _isListening;

  // ============================================================
  // REALTIME LISTENER
  // ============================================================

  void listenToProjects() {
    if (_isListening) {
      return;
    }

    _startListening();
  }

  Future<void> _startListening() async {
    // На всякий случай отменяем старую подписку.
    await _projectsSubscription?.cancel();
    _projectsSubscription = null;

    _isListening = true;
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _projectsSubscription = repository.getUserProjectsStream().listen(
        (projects) {
          if (_isDisposed) return;

          _projects = projects;
          _isLoading = false;
          _error = null;

          notifyListeners();
        },
        onError: (error) {
          if (_isDisposed) return;

          _isLoading = false;
          _error = 'Ошибка при загрузке проектов: $error';

          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (_isDisposed) return;

      _isListening = false;
      _isLoading = false;
      _error = 'Ошибка при подключении к проектам: $e';

      notifyListeners();
    }
  }

  // ============================================================
  // RESTART LISTENER
  // ============================================================

  Future<void> restartListening() async {
    await stopListening();

    if (_isDisposed) return;

    _projects = [];
    _error = null;
    _isLoading = true;

    notifyListeners();

    await _startListening();
  }

  // ============================================================
  // STOP LISTENER
  // ============================================================

  Future<void> stopListening() async {
    final subscription = _projectsSubscription;

    _projectsSubscription = null;
    _isListening = false;

    if (subscription != null) {
      await subscription.cancel();
    }
  }

  // ============================================================
  // ОДНОРАЗОВАЯ ЗАГРУЗКА
  // ============================================================

  Future<void> loadProjects() async {
    if (_isDisposed) return;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final projects = await repository.getUserProjects();

      if (_isDisposed) return;

      _projects = projects;
      _error = null;
    } catch (e) {
      if (_isDisposed) return;

      _error = 'Ошибка при загрузке проектов: $e';
    } finally {
      if (_isDisposed) return;

      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // СОЗДАНИЕ ПРОЕКТА
  // ============================================================

  Future<void> createProject(String title, {String description = ''}) async {
    if (_isDisposed) return;

    try {
      _error = null;

      notifyListeners();

      final project = await repository.createProject(
        title: title,
        description: description,
      );

      if (_isDisposed) return;

      // Если realtime listener работает,
      // Firestore сам пришлёт новый список.
      if (!_isListening) {
        _projects.insert(0, project);
        notifyListeners();
      }
    } catch (e) {
      if (_isDisposed) return;

      _error = 'Ошибка при создании проекта: $e';

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // УДАЛЕНИЕ ПРОЕКТА
  // ============================================================

  Future<void> deleteProject(String projectId) async {
    if (_isDisposed) return;

    try {
      _error = null;

      await repository.deleteProject(projectId);

      if (_isDisposed) return;

      // При активном listener Firestore сам обновит список.
      if (!_isListening) {
        _projects.removeWhere((project) => project.id == projectId);

        notifyListeners();
      }
    } catch (e) {
      if (_isDisposed) return;

      _error = 'Ошибка при удалении проекта: $e';

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // ПОЛУЧИТЬ ПРОЕКТЫ ПО СТАТУСУ
  // ============================================================

  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }

  // ============================================================
  // ПОЛУЧИТЬ ПРОЕКТ ПО ID
  // ============================================================

  Project? getProjectById(String id) {
    for (final project in _projects) {
      if (project.id == id) {
        return project;
      }
    }

    return null;
  }

  // ============================================================
  // ИЗМЕНЕНИЕ СТАТУСА
  // ============================================================

  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    if (_isDisposed) return;

    try {
      _error = null;

      await repository.updateProjectStatus(projectId, status);

      if (_isDisposed) return;

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
      if (_isDisposed) return;

      _error = 'Ошибка при изменении статуса: $e';

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // ИЗМЕНЕНИЕ ПРОГРЕССА
  // ============================================================

  Future<void> updateProjectProgress(String projectId, double progress) async {
    if (_isDisposed) return;

    final normalizedProgress = progress.clamp(0.0, 1.0);

    try {
      _error = null;

      await repository.updateProjectProgress(projectId, normalizedProgress);

      if (_isDisposed) return;

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
      if (_isDisposed) return;

      _error = 'Ошибка при обновлении прогресса: $e';

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // СТАТИСТИКА ПО СТАТУСАМ
  // ============================================================

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

  // ============================================================
  // DISPOSE
  // ============================================================

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;

    _projectsSubscription?.cancel();
    _projectsSubscription = null;

    super.dispose();
  }
}
