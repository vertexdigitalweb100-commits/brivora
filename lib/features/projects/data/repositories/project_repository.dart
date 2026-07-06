import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/project.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Коллекция проектов в Firestore
  static const String _projectsCollection = 'projects';

  /// Получить текущего пользователя
  String? get currentUserId => _auth.currentUser?.uid;

  /// Создать новый проект в Firestore
  Future<Project> createProject({
    required String title,
    required String description,
  }) async {
    if (currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }

    final projectId = _firestore.collection(_projectsCollection).doc().id;
    final now = DateTime.now();

    final project = Project(
      id: projectId,
      title: title,
      description: description,
      ownerId: currentUserId!,
      createdAt: now,
      progress: 0.0,
      status: ProjectStatus.active,
    );

    await _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .set(project.toFirestore());

    return project;
  }

  /// Получить все проекты текущего пользователя
  Future<List<Project>> getUserProjects() async {
    if (currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }

    try {
      final snapshot = await _firestore
          .collection(_projectsCollection)
          .where('ownerId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Project.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка при загрузке проектов: $e');
      rethrow;
    }
  }

  /// Получить поток проектов (для реал-тайм обновлений)
  Stream<List<Project>> getUserProjectsStream() {
    if (currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }

    return _firestore
        .collection(_projectsCollection)
        .where('ownerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Project.fromFirestore(doc.data()))
          .toList();
    }).handleError((e) {
      print('Ошибка потока проектов: $e');
      return <Project>[];
    });
  }

  /// Получить проект по ID
  Future<Project?> getProjectById(String projectId) async {
    try {
      final doc = await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .get();

      if (doc.exists) {
        final project = Project.fromFirestore(doc.data()!);
        // Проверяем, что это проект текущего пользователя
        if (project.ownerId == currentUserId) {
          return project;
        }
      }
      return null;
    } catch (e) {
      print('Ошибка при загрузке проекта: $e');
      rethrow;
    }
  }

  /// Обновить проект
  Future<void> updateProject(Project project) async {
    if (project.ownerId != currentUserId) {
      throw Exception('Вы не можете редактировать чужой проект');
    }

    try {
      final updatedProject = project.copyWith(
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(_projectsCollection)
          .doc(project.id)
          .set(updatedProject.toFirestore());
    } catch (e) {
      print('Ошибка при обновлении проекта: $e');
      rethrow;
    }
  }

  /// Удалить проект
  Future<void> deleteProject(String projectId) async {
    try {
      // Проверяем, что это проект текущего пользователя
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Проект не найден или вы не имеете доступа');
      }

      await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .delete();
    } catch (e) {
      print('Ошибка при удалении проекта: $e');
      rethrow;
    }
  }

  /// Обновить статус проекта
  Future<void> updateProjectStatus(String projectId, ProjectStatus status) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Проект не найден');
      }

      await updateProject(project.copyWith(status: status));
    } catch (e) {
      print('Ошибка при изменении статуса: $e');
      rethrow;
    }
  }

  /// Обновить прогресс проекта
  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Проект не найден');
      }

      await updateProject(
        project.copyWith(progress: progress.clamp(0.0, 1.0)),
      );
    } catch (e) {
      print('Ошибка при обновлении прогресса: $e');
      rethrow;
    }
  }

  /// Проверить наличие проектов у пользователя
  Future<int> getProjectCount() async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _firestore
          .collection(_projectsCollection)
          .where('ownerId', isEqualTo: currentUserId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Ошибка при подсчете проектов: $e');
      return 0;
    }
  }
}
