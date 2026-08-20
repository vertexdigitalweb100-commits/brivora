import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/project.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _projectsCollection = 'projects';

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _projectsCollectionRef =>
      _firestore.collection(_projectsCollection);

  // ============================================================
  // CREATE
  // ============================================================

  Future<Project> createProject({
    required String title,
    required String description,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    final doc = _projectsCollectionRef.doc();

    final project = Project(
      id: doc.id,
      title: title.trim(),
      description: description.trim(),
      ownerId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      progress: 0.0,
      status: ProjectStatus.active,
      coverImageUrl: null,
      members: const [],
    );

    await doc.set(project.toFirestore());

    return project;
  }

  // ============================================================
  // GET PROJECTS
  // ============================================================

  Future<List<Project>> getUserProjects() async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    final snapshot = await _projectsCollectionRef
        .where('ownerId', isEqualTo: userId)
        .get();

    final projects = <Project>[];

    for (final doc in snapshot.docs) {
      try {
        final project = Project.fromFirestore(doc.data(), documentId: doc.id);

        projects.add(project);
      } catch (e) {
        // Один повреждённый документ не должен
        // ломать загрузку всех проектов.
        continue;
      }
    }

    projects.sort(_compareByRecent);

    return projects;
  }

  // ============================================================
  // REALTIME PROJECTS STREAM
  // ============================================================

  Stream<List<Project>> getUserProjectsStream() {
    final userId = currentUserId;

    if (userId == null) {
      return Stream.value(const []);
    }

    return _projectsCollectionRef
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final projects = <Project>[];

          for (final doc in snapshot.docs) {
            try {
              final project = Project.fromFirestore(
                doc.data(),
                documentId: doc.id,
              );

              projects.add(project);
            } catch (_) {
              // Пропускаем только повреждённый документ.
              // Остальные проекты продолжают отображаться.
              continue;
            }
          }

          projects.sort(_compareByRecent);

          return projects;
        });
  }

  // ============================================================
  // SORT
  // ============================================================

  int _compareByRecent(Project a, Project b) {
    final aDate = a.updatedAt ?? a.createdAt;
    final bDate = b.updatedAt ?? b.createdAt;

    return bDate.compareTo(aDate);
  }

  // ============================================================
  // GET ONE PROJECT
  // ============================================================

  Future<Project?> getProjectById(String projectId) async {
    final userId = currentUserId;

    if (userId == null) {
      return null;
    }

    if (projectId.trim().isEmpty) {
      return null;
    }

    final doc = await _projectsCollectionRef.doc(projectId).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    final project = Project.fromFirestore(data, documentId: doc.id);

    if (project.ownerId != userId) {
      return null;
    }

    return project;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateProject(Project project) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    if (project.ownerId != userId) {
      throw Exception('Нет доступа к проекту');
    }

    if (project.id.trim().isEmpty) {
      throw Exception('Некорректный ID проекта');
    }

    final updatedProject = project.copyWith(updatedAt: DateTime.now());

    await _projectsCollectionRef
        .doc(project.id)
        .set(updatedProject.toFirestore());
  }

  // ============================================================
  // COVER
  // ============================================================

  Future<void> setProjectCover(String projectId, String imageUrl) async {
    final project = await getProjectById(projectId);

    if (project == null) {
      throw Exception('Проект не найден');
    }

    await _projectsCollectionRef.doc(projectId).update({
      'coverImageUrl': imageUrl,
      'updatedAt': Timestamp.now(),
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteProject(String projectId) async {
    final project = await getProjectById(projectId);

    if (project == null) {
      throw Exception('Проект не найден');
    }

    await _projectsCollectionRef.doc(projectId).delete();
  }

  // ============================================================
  // STATUS
  // ============================================================

  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    final project = await getProjectById(projectId);

    if (project == null) {
      throw Exception('Проект не найден');
    }

    await updateProject(project.copyWith(status: status));
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Future<void> updateProjectProgress(String projectId, double progress) async {
    final project = await getProjectById(projectId);

    if (project == null) {
      throw Exception('Проект не найден');
    }

    await updateProject(project.copyWith(progress: progress.clamp(0.0, 1.0)));
  }

  // ============================================================
  // COUNT
  // ============================================================

  Future<int> getProjectCount() async {
    final userId = currentUserId;

    if (userId == null) {
      return 0;
    }

    final snapshot = await _projectsCollectionRef
        .where('ownerId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}
