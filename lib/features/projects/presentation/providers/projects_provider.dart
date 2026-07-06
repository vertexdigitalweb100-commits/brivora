import 'package:flutter/material.dart';
import '../../data/repositories/project_repository.dart';
import '../../domain/models/project.dart';

class ProjectsProvider extends ChangeNotifier {
  final ProjectRepository repository = ProjectRepository();

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  /// Получить все проекты
  List<Project> get projects => List.unmodifiable(_projects);

  /// Статус загрузки
  bool get isLoading => _isLoading;

  /// Ошибка (если есть)
  String? get error => _error;

  /// Инициализировать и загрузить проекты
  Future<void> loadProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await repository.getUserProjects();
      _error = null;
    } catch (e) {
      _error = 'Ошибка при загрузке проектов: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Создать новый проект
  Future<void> createProject(String title, {String description = ''}) async {
    try {
      final project = await repository.createProject(
        title: title,
        description: description,
      );
      _projects.insert(0, project);
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при создании проекта: $e';
      print(_error);
      rethrow;
    }
  }

  /// Удалить проект
  Future<void> deleteProject(String projectId) async {
    try {
      await repository.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при удалении проекта: $e';
      print(_error);
      rethrow;
    }
  }

  /// Получить проекты по статусу
  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((p) => p.status == status).toList();
  }

  /// Получить проект по ID
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Изменить статус проекта
  Future<void> updateProjectStatus(String projectId, ProjectStatus status) async {
    try {
      await repository.updateProjectStatus(projectId, status);
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = _projects[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка при изменении статуса: $e';
      print(_error);
      rethrow;
    }
  }

  /// Изменить прогресс проекта
  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      await repository.updateProjectProgress(projectId, progress.clamp(0.0, 1.0));
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = _projects[index].copyWith(progress: progress.clamp(0.0, 1.0));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка при обновлении прогресса: $e';
      print(_error);
      rethrow;
    }
  }

  /// Получить количество проектов по статусам
  Map<ProjectStatus, int> getProjectCountByStatus() {
    return {
      ProjectStatus.active: _projects.where((p) => p.status == ProjectStatus.active).length,
      ProjectStatus.planning: _projects.where((p) => p.status == ProjectStatus.planning).length,
      ProjectStatus.completed: _projects.where((p) => p.status == ProjectStatus.completed).length,
      ProjectStatus.archived: _projects.where((p) => p.status == ProjectStatus.archived).length,
    };
  }
}
