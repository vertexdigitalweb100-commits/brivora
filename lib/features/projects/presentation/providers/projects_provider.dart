import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/project_repository.dart';
import '../../domain/models/project.dart';

class ProjectsProvider extends ChangeNotifier {
  final ProjectRepository repository = ProjectRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Project> _projects = [];

  StreamSubscription<List<Project>>? _projectsSubscription;
  StreamSubscription<User?>? _authSubscription;

  bool _isLoading = false;
  bool _disposed = false;
  bool _isListening = false;

  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isListening => _projectsSubscription != null && _isListening;

  // ============================================================
  // START LISTENING
  // ============================================================

  void listenToProjects() {
    if (_disposed) return;

    debugPrint('PROJECTS PROVIDER: listenToProjects()');

    if (_isListening && _projectsSubscription != null) {
      debugPrint('PROJECTS PROVIDER: listener already active');
      return;
    }

    _startListening();
  }

  void _startListening() {
    if (_disposed) return;

    _isLoading = true;
    _error = null;
    _isListening = false;

    _safeNotify();

    final user = _auth.currentUser;

    debugPrint('PROJECTS PROVIDER: current user = ${user?.uid}');

    if (user == null) {
      debugPrint('PROJECTS PROVIDER: user is null, waiting for auth');

      _listenForAuth();

      return;
    }

    _subscribeToProjects();
  }

  // ============================================================
  // AUTH
  // ============================================================

  void _listenForAuth() {
    if (_disposed) return;

    _authSubscription?.cancel();

    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        if (_disposed) return;

        debugPrint('PROJECTS PROVIDER: auth changed -> ${user?.uid}');

        if (user == null) {
          _isListening = false;
          _isLoading = false;
          _projects.clear();
          _error = null;

          _safeNotify();
          return;
        }

        _authSubscription?.cancel();
        _authSubscription = null;

        _subscribeToProjects();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;

        debugPrint('PROJECTS PROVIDER AUTH ERROR: $error');
        debugPrint(stackTrace.toString());

        _isLoading = false;
        _error = error.toString();

        _safeNotify();
      },
    );
  }

  // ============================================================
  // FIRESTORE LISTENER
  // ============================================================

  void _subscribeToProjects() {
    if (_disposed) return;

    _projectsSubscription?.cancel();
    _projectsSubscription = null;

    _isLoading = true;
    _error = null;
    _isListening = false;

    _safeNotify();

    debugPrint('PROJECTS PROVIDER: starting Firestore listener');

    late final Stream<List<Project>> stream;

    try {
      stream = repository.getUserProjectsStream();
    } catch (e, stackTrace) {
      debugPrint('PROJECTS PROVIDER: stream creation error: $e');
      debugPrint(stackTrace.toString());

      _isLoading = false;
      _isListening = false;
      _error = e.toString();

      _safeNotify();
      return;
    }

    _projectsSubscription = stream.listen(
      (projects) {
        if (_disposed) return;

        debugPrint('PROJECTS PROVIDER: received ${projects.length} projects');

        _projects
          ..clear()
          ..addAll(projects);

        _isLoading = false;
        _isListening = true;
        _error = null;

        _safeNotify();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;

        debugPrint('PROJECTS PROVIDER FIRESTORE ERROR: $error');
        debugPrint(stackTrace.toString());

        _isLoading = false;
        _isListening = false;
        _error = error.toString();

        _projectsSubscription?.cancel();
        _projectsSubscription = null;

        _safeNotify();
      },
      onDone: () {
        if (_disposed) return;

        debugPrint('PROJECTS PROVIDER: Firestore listener DONE');

        _isListening = false;
        _projectsSubscription = null;

        if (_projects.isEmpty && _error == null) {
          _isLoading = false;
          _safeNotify();
        }
      },
      cancelOnError: false,
    );
  }

  // ============================================================
  // RESTART
  // ============================================================

  Future<void> restartListening() async {
    if (_disposed) return;

    debugPrint('PROJECTS PROVIDER: restarting listener');

    await _projectsSubscription?.cancel();
    await _authSubscription?.cancel();

    _projectsSubscription = null;
    _authSubscription = null;

    _isListening = false;
    _isLoading = true;
    _error = null;

    _projects.clear();

    _safeNotify();

    _startListening();
  }

  // ============================================================
  // STOP
  // ============================================================

  Future<void> stopListening() async {
    debugPrint('PROJECTS PROVIDER: stopListening()');

    await _projectsSubscription?.cancel();
    await _authSubscription?.cancel();

    _projectsSubscription = null;
    _authSubscription = null;

    _isListening = false;
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

      debugPrint('PROJECTS PROVIDER: loaded ${projects.length} projects');
    } catch (e, stackTrace) {
      if (_disposed) return;

      debugPrint('PROJECTS PROVIDER LOAD ERROR: $e');
      debugPrint(stackTrace.toString());

      _error = e.toString();
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

      /*
       * Если listener уже работает,
       * Firestore сам вернёт новый проект.
       */
      if (!_isListening) {
        _projects.insert(0, project);
        _safeNotify();
      }
    } catch (e, stackTrace) {
      if (_disposed) return;

      debugPrint('PROJECTS PROVIDER CREATE ERROR: $e');
      debugPrint(stackTrace.toString());

      _error = e.toString();

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

      if (!_isListening) {
        _projects.removeWhere((project) => project.id == projectId);

        _safeNotify();
      }
    } catch (e, stackTrace) {
      if (_disposed) return;

      debugPrint('PROJECTS PROVIDER DELETE ERROR: $e');
      debugPrint(stackTrace.toString());

      _error = e.toString();

      _safeNotify();

      rethrow;
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    if (_disposed) return;

    try {
      await repository.updateProjectStatus(projectId, status);

      if (_disposed) return;

      if (!_isListening) {
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

      debugPrint('PROJECTS PROVIDER STATUS ERROR: $e');
      debugPrint(stackTrace.toString());

      _error = e.toString();

      _safeNotify();

      rethrow;
    }
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Future<void> updateProjectProgress(String projectId, double progress) async {
    if (_disposed) return;

    final normalized = progress.clamp(0.0, 1.0);

    try {
      await repository.updateProjectProgress(projectId, normalized);

      if (_disposed) return;

      if (!_isListening) {
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

      debugPrint('PROJECTS PROVIDER PROGRESS ERROR: $e');
      debugPrint(stackTrace.toString());

      _error = e.toString();

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

    _projectsSubscription?.cancel();
    _authSubscription?.cancel();

    _projectsSubscription = null;
    _authSubscription = null;

    super.dispose();
  }
}
