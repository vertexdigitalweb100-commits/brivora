import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    final doc = _projectsCollectionRef.doc();

    final now = DateTime.now();

    final project = Project(
      id: doc.id,
      title: title.trim(),
      description: description.trim(),
      ownerId: user.uid,
      createdAt: now,
      updatedAt: now,
      progress: 0.0,
      status: ProjectStatus.active,
      coverImageUrl: null,
      members: const [],
    );

    await doc.set(project.toFirestore());

    debugPrint('PROJECT CREATED: ${project.id}');

    return project;
  }

  // ============================================================
  // GET PROJECTS
  // ============================================================

  Future<List<Project>> getUserProjects() async {
    final userId = currentUserId;

    debugPrint('PROJECT REPOSITORY: getUserProjects UID=$userId');

    if (userId == null) {
      return [];
    }

    try {
      final snapshot = await _projectsCollectionRef
          .where('ownerId', isEqualTo: userId)
          .get();

      debugPrint('PROJECT REPOSITORY: documents=${snapshot.docs.length}');

      final projects = <Project>[];

      for (final doc in snapshot.docs) {
        try {
          final project = Project.fromFirestore(doc.data(), documentId: doc.id);

          projects.add(project);

          debugPrint('PROJECT: ${project.id} | ${project.title}');
        } catch (e, stackTrace) {
          debugPrint('PROJECT PARSE ERROR: ${doc.id}');
          debugPrint('$e');
          debugPrint(stackTrace.toString());
        }
      }

      projects.sort(_compareByRecent);

      debugPrint('PROJECT REPOSITORY: final=${projects.length}');

      return projects;
    } catch (e, stackTrace) {
      debugPrint('PROJECT REPOSITORY GET ERROR: $e');
      debugPrint(stackTrace.toString());

      rethrow;
    }
  }

  // ============================================================
  // REALTIME STREAM
  // ============================================================

  Stream<List<Project>> getUserProjectsStream() {
    final userId = currentUserId;

    debugPrint('PROJECT STREAM CREATED: UID=$userId');

    if (userId == null) {
      return Stream.error(Exception('FirebaseAuth.currentUser == null'));
    }

    return _projectsCollectionRef
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            'PROJECT STREAM SNAPSHOT: '
            '${snapshot.docs.length} documents',
          );

          final projects = <Project>[];

          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();

              debugPrint(
                'PROJECT DOCUMENT: '
                '${doc.id} '
                'owner=${data['ownerId']} '
                'title=${data['title']}',
              );

              final project = Project.fromFirestore(data, documentId: doc.id);

              projects.add(project);
            } catch (e, stackTrace) {
              debugPrint('PROJECT STREAM PARSE ERROR: ${doc.id}');
              debugPrint('$e');
              debugPrint(stackTrace.toString());
            }
          }

          projects.sort(_compareByRecent);

          debugPrint('PROJECT STREAM RESULT: ${projects.length}');

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
  // GET ONE
  // ============================================================

  Future<Project?> getProjectById(String projectId) async {
    final userId = currentUserId;

    if (userId == null) {
      return null;
    }

    if (projectId.trim().isEmpty) {
      return null;
    }

    try {
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
        debugPrint('PROJECT ACCESS DENIED: ${project.id}');

        return null;
      }

      return project;
    } catch (e, stackTrace) {
      debugPrint('GET PROJECT ERROR: $e');
      debugPrint(stackTrace.toString());

      rethrow;
    }
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

    try {
      final snapshot = await _projectsCollectionRef
          .where('ownerId', isEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      debugPrint('PROJECT COUNT ERROR: $e');
      debugPrint(stackTrace.toString());

      rethrow;
    }
  }
}
