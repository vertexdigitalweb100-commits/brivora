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
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    final doc = _projectsCollectionRef.doc();
    final now = DateTime.now();

    final project = Project(
      id: doc.id,
      title: title.trim(),
      description: description.trim(),
      ownerId: userId,
      createdAt: now,
      updatedAt: now,
      progress: 0.0,
      status: ProjectStatus.active,
      coverImageUrl: null,
      members: const [],
    );

    await doc.set(project.toFirestore());

    debugPrint('========== PROJECT CREATED ==========');
    debugPrint('Project ID: ${project.id}');
    debugPrint('Owner ID: ${project.ownerId}');
    debugPrint('Title: ${project.title}');
    debugPrint('=====================================');

    return project;
  }

  // ============================================================
  // GET PROJECTS
  // ============================================================

  Future<List<Project>> getUserProjects() async {
    final userId = currentUserId;

    debugPrint('========== GET USER PROJECTS ==========');
    debugPrint('Current Firebase UID: $userId');

    if (userId == null) {
      debugPrint('GET PROJECTS: user is not authenticated');
      debugPrint('======================================');
      return [];
    }

    try {
      final snapshot = await _projectsCollectionRef
          .where('ownerId', isEqualTo: userId)
          .get();

      debugPrint('Documents received: ${snapshot.docs.length}');

      final projects = <Project>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          debugPrint('--------------------------------------');
          debugPrint('Document ID: ${doc.id}');
          debugPrint('ownerId: ${data['ownerId']}');
          debugPrint('title: ${data['title']}');
          debugPrint('fields: ${data.keys.toList()}');

          final project = Project.fromFirestore(data, documentId: doc.id);

          debugPrint('Parsed project ID: ${project.id}');
          debugPrint('Parsed project title: ${project.title}');
          debugPrint('Parsed project ownerId: ${project.ownerId}');

          projects.add(project);
        } catch (e, stackTrace) {
          debugPrint('PROJECT PARSE ERROR');
          debugPrint('Document ID: ${doc.id}');
          debugPrint('Error: $e');
          debugPrint(stackTrace.toString());
        }
      }

      projects.sort(_compareByRecent);

      debugPrint('FINAL PROJECTS COUNT: ${projects.length}');
      debugPrint('======================================');

      return projects;
    } catch (e, stackTrace) {
      debugPrint('========== GET PROJECTS ERROR ==========');
      debugPrint('Error: $e');
      debugPrint(stackTrace.toString());
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // REALTIME PROJECTS STREAM
  // ============================================================

  Stream<List<Project>> getUserProjectsStream() {
    final userId = currentUserId;

    debugPrint('========== BRIVORA PROJECTS DEBUG ==========');
    debugPrint('Current Firebase UID: $userId');

    if (userId == null) {
      debugPrint('PROJECTS ERROR: currentUserId == null');
      debugPrint('============================================');

      return Stream.value(const []);
    }

    return _projectsCollectionRef
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          debugPrint('========== FIRESTORE PROJECTS ==========');
          debugPrint('Current UID: $userId');
          debugPrint('Documents received: ${snapshot.docs.length}');

          final projects = <Project>[];

          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();

              debugPrint('----------------------------------------');
              debugPrint('Document ID: ${doc.id}');
              debugPrint('Document ownerId: ${data['ownerId']}');
              debugPrint('Document title: ${data['title']}');
              debugPrint('Document fields: ${data.keys.toList()}');

              final project = Project.fromFirestore(data, documentId: doc.id);

              debugPrint('Parsed project ID: ${project.id}');

              debugPrint('Parsed project title: ${project.title}');

              debugPrint('Parsed project ownerId: ${project.ownerId}');

              projects.add(project);
            } catch (e, stackTrace) {
              debugPrint('PROJECT PARSE ERROR');
              debugPrint('Document ID: ${doc.id}');
              debugPrint('Error: $e');
              debugPrint(stackTrace.toString());
            }
          }

          projects.sort(_compareByRecent);

          debugPrint('----------------------------------------');
          debugPrint('FINAL PROJECTS COUNT: ${projects.length}');
          debugPrint('==========================================');

          return projects;
        })
        .handleError((Object error, StackTrace stackTrace) {
          debugPrint('========== FIRESTORE STREAM ERROR ==========');

          debugPrint('Current UID: $userId');
          debugPrint('Error: $error');
          debugPrint(stackTrace.toString());

          debugPrint('=============================================');
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

    try {
      final doc = await _projectsCollectionRef.doc(projectId).get();

      if (!doc.exists) {
        debugPrint('GET PROJECT: document does not exist: $projectId');

        return null;
      }

      final data = doc.data();

      if (data == null) {
        debugPrint('GET PROJECT: document data is null: $projectId');

        return null;
      }

      debugPrint('========== GET PROJECT ==========');
      debugPrint('Document ID: ${doc.id}');
      debugPrint('Current UID: $userId');
      debugPrint('ownerId: ${data['ownerId']}');
      debugPrint('title: ${data['title']}');
      debugPrint('=================================');

      final project = Project.fromFirestore(data, documentId: doc.id);

      if (project.ownerId != userId) {
        debugPrint('GET PROJECT: access denied for project ${project.id}');

        return null;
      }

      return project;
    } catch (e, stackTrace) {
      debugPrint('========== GET PROJECT ERROR ==========');
      debugPrint('Project ID: $projectId');
      debugPrint('Error: $e');
      debugPrint(stackTrace.toString());
      debugPrint('=======================================');

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

    try {
      await _projectsCollectionRef
          .doc(project.id)
          .set(updatedProject.toFirestore());

      debugPrint('PROJECT UPDATED: ${project.id}');
    } catch (e, stackTrace) {
      debugPrint('========== UPDATE PROJECT ERROR ==========');
      debugPrint('Project ID: ${project.id}');
      debugPrint('Error: $e');
      debugPrint(stackTrace.toString());
      debugPrint('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // COVER
  // ============================================================

  Future<void> setProjectCover(String projectId, String imageUrl) async {
    final project = await getProjectById(projectId);

    if (project == null) {
      throw Exception('Проект не найден');
    }

    try {
      await _projectsCollectionRef.doc(projectId).update({
        'coverImageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });

      debugPrint('PROJECT COVER UPDATED: $projectId');
    } catch (e, stackTrace) {
      debugPrint('========== COVER UPDATE ERROR ==========');
      debugPrint('Project ID: $projectId');
      debugPrint('Error: $e');
      debugPrint(stackTrace.toString());
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteProject(String projectId) async {
    final project = await getProjectById(projectId);

    if (project == null) {
      throw Exception('Проект не найден');
    }

    try {
      await _projectsCollectionRef.doc(projectId).delete();

      debugPrint('PROJECT DELETED: $projectId');
    } catch (e, stackTrace) {
      debugPrint('========== DELETE PROJECT ERROR ==========');
      debugPrint('Project ID: $projectId');
      debugPrint('Error: $e');
      debugPrint(stackTrace.toString());
      debugPrint('==========================================');

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

      final count = snapshot.count ?? 0;

      debugPrint('PROJECT COUNT: $count');

      return count;
    } catch (e, stackTrace) {
      debugPrint('========== PROJECT COUNT ERROR ==========');
      debugPrint('Current UID: $userId');
      debugPrint('Error: $e');
      debugPrint(stackTrace.toString());
      debugPrint('=========================================');

      rethrow;
    }
  }
}
