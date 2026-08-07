import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  Future<Task> createTask(Task task) async {
    final doc = _tasksCollection.doc();
    final newTask = task.copyWith(
      id: doc.id,
      createdAt: DateTime.now(),
    );

    await doc.set(newTask.toFirestore());
    return newTask;
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toFirestore());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Stream<List<Task>> getProjectTasks(String projectId) {
    return _tasksCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromFirestore(doc))
            .toList());
  }

  Future<void> updateTaskStatus(
    String taskId,
    TaskStatus status,
    DateTime? completedAt,
  ) async {
    await _tasksCollection.doc(taskId).update({
      'status': status.name,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt) : null,
      'updatedAt': Timestamp.now(),
    });
  }
}
