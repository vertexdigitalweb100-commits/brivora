import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/project.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _projectsCollection = 'projects';

  String? get currentUserId => _auth.currentUser?.uid;

  Future<Project> createProject({
    required String title,
    required String description,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    final doc = _firestore.collection(_projectsCollection).doc();

    final project = Project(
      id: doc.id,
      title: title,
      description: description,
      ownerId: userId,
      createdAt: DateTime.now(),
      progress: 0.0,
      status: ProjectStatus.active,
      coverImageUrl: null,
    );

    await doc.set(project.toFirestore());

    return project;
  }

  Future<List<Project>> getUserProjects() async {
    final userId = currentUserId;
    if (userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection(_projectsCollection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Project.fromFirestore(doc.data()))
        .toList();
  }

  Stream<List<Project>> getUserProjectsStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_projectsCollection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Project.fromFirestore(doc.data()))
              .toList(),
        );
  }

  Future<Project?> getProjectById(String projectId) async {
    final userId = currentUserId;
    if (userId == null) {
      return null;
    }

    final doc = await _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .get();

    final data = doc.data();
    if (!doc.exists || data == null) {
      return null;
    }

    final project = Project.fromFirestore(data);
    if (project.ownerId != userId) {
      return null;
    }

    return project;
  }

  Future<void> updateProject(Project project) async {
    await _firestore
        .collection(_projectsCollection)
        .doc(project.id)
        .set(project.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  /// ⭐ Установить обложку проекта
  Future<void> setProjectCover(String projectId, String imageUrl) async {
    await _firestore.collection(_projectsCollection).doc(projectId).update({
      'coverImageUrl': imageUrl,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteProject(String projectId) async {
    await _firestore.collection(_projectsCollection).doc(projectId).delete();
  }

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

  Future<void> updateProjectProgress(String projectId, double progress) async {
    final project = await getProjectById(projectId);

    if (project == null) {
      throw Exception('Проект не найден');
    }

    await updateProject(project.copyWith(progress: progress.clamp(0.0, 1.0)));
  }

  Future<int> getProjectCount() async {
    final snapshot = await _firestore
        .collection(_projectsCollection)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}
