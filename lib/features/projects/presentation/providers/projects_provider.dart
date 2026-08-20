import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/project_repository.dart';
import '../../domain/models/project.dart';

class ProjectsProvider extends ChangeNotifier {
  final ProjectRepository repository = ProjectRepository();

  final List<Project> _projects = [];

  StreamSubscription<List<Project>>? _subscription;

  bool _isLoading = false;
  bool _isStarted = false;
  bool _disposed = false;

  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isListening => _subscription != null;

  // ============================================================
  // START
  // ============================================================

  void listenToProjects() {
    if (_disposed) return;

    // Уже слушаем Firebase.
    // Ничего повторно создавать не нужно.
    if (_subscription != null) {
      return;
    }

    _startListener();
  }

  Future<void> _startListener() async {
    if (_disposed) return;

    _isStarted = true;
    _isLoading = true;
    _error = null;

    _safeNotify();

    try {
      final stream = repository.getUserProjectsStream();

      _subscription = stream.listen(
        (projects) {
          if (_disposed) return;

          _projects
            ..clear()
            ..addAll(projects);

          _isLoading = false;
          _error = null;

          debugPrint('ProjectsProvider: received ${projects.length} projects');

          _safeNotify();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_disposed) return;

          _isLoading = false;
          _error = error.toString();

          debugPrint('ProjectsProvider FIRESTORE ERROR: $error');

          debugPrint(stackTrace.toString());

          _safeNotify();
        },
        cancelOnError: false,
      );
    } catch (e, stackTrace) {
      if (_disposed) return;

      _subscription = null;
      _isLoading = false;
      _error = e.toString();

      debugPrint('ProjectsProvider START ERROR: $e');

      debugPrint(stackTrace.toString());

      _safeNotify();
    }
  }

  // ============================================================
  // RESTART
  // ============================================================

  Future<void> restartListening() async {
    if (_disposed) return;

    debugPrint('ProjectsProvider: restarting listener');

    await _subscription?.cancel();

    _subscription = null;

    _projects.clear();

    _isLoading = true;
    _error = null;

    _safeNotify();

    await _startListener();
  }

  // ============================================================
  // STOP
  // ============================================================

  Future<void> stopListening() async {
    await _subscription?.cancel();

    _subscription = null;
  }

  // ============================================================
  // LOAD ONCE
  // ============================================================

  Future<void> loadProjects() async {
    if (_disposed) return;

    _isLoading = true;
    _error = null;

    _safeNotify();

    try {
      final projects = await repository.getUserProjects();

      if (_disposed) return;

      _projects
        ..clear()
        ..addAll(projects);

      _error = null;

      debugPrint('ProjectsProvider: loaded ${projects.length} projects');
    } catch (e, stackTrace) {
      if (_disposed) return;

      _error = e.toString();

      debugPrint('ProjectsProvider LOAD ERROR: $e');

      debugPrint(stackTrace.toString());
    } finally {
      if (_disposed) return;

      _isLoading = false;

      _safeNotify();
    }
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<void> createProject(String title, {String description = ''}) async {
    if (_disposed) return;

    try {
      _error = null;

      final project = await repository.createProject(
        title: title,
        description: description,
      );

      if (_disposed) return;

      // Если listener не запущен,
      // добавляем проект вручную.
      if (_subscription == null) {
        _projects.insert(0, project);
        _safeNotify();
      }
    } catch (e, stackTrace) {
      if (_disposed) return;

      _error = e.toString();

      debugPrint('ProjectsProvider CREATE ERROR: $e');

      debugPrint(stackTrace.toString());

      _safeNotify();

      rethrow;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteProject(String projectId) async {
    if (_disposed) return;

    try {
      await repository.deleteProject(projectId);

      if (_disposed) return;

      if (_subscription == null) {
        _projects.removeWhere((project) => project.id == projectId);

        _safeNotify();
      }
    } catch (e, stackTrace) {
      if (_disposed) return;

      _error = e.toString();

      debugPrint('ProjectsProvider DELETE ERROR: $e');

      debugPrint(stackTrace.toString());

      _safeNotify();

      rethrow;
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    if (_disposed) return;

    try {
      await repository.updateProjectStatus(projectId, status);

      if (_disposed) return;

      if (_subscription == null) {
        final index = _projects.indexWhere(
          (project) => project.id == projectId,
        );

        if (index != -1) {
          _projects[index] = _projects[index].copyWith(status: status);

          _safeNotify();
        }
      }
    } catch (e, stackTrace) {
      if (_disposed) return;

      _error = e.toString();

      debugPrint('ProjectsProvider STATUS ERROR: $e');

      debugPrint(stackTrace.toString());

      _safeNotify();

      rethrow;
    }
  }

  // ============================================================
  // UPDATE PROGRESS
  // ============================================================

  Future<void> updateProjectProgress(String projectId, double progress) async {
    if (_disposed) return;

    final normalized = progress.clamp(0.0, 1.0);

    try {
      await repository.updateProjectProgress(projectId, normalized);

      if (_disposed) return;

      if (_subscription == null) {
        final index = _projects.indexWhere(
          (project) => project.id == projectId,
        );

        if (index != -1) {
          _projects[index] = _projects[index].copyWith(progress: normalized);

          _safeNotify();
        }
      }
    } catch (e, stackTrace) {
      if (_disposed) return;

      _error = e.toString();

      debugPrint('ProjectsProvider PROGRESS ERROR: $e');

      debugPrint(stackTrace.toString());

      _safeNotify();

      rethrow;
    }
  }

  // ============================================================
  // GET BY ID
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
  // GET BY STATUS
  // ============================================================

  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }

  // ============================================================
  // COUNTS
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
  // SAFE NOTIFY
  // ============================================================

  void _safeNotify() {
    if (_disposed) return;

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposed = true;

    _subscription?.cancel();
    _subscription = null;

    super.dispose();
  }
}
