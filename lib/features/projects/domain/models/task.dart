import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { active, inProgress, completed }

enum TaskPriority { low, normal, high }

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.active:
        return 'Активная';
      case TaskStatus.inProgress:
        return 'В процессе';
      case TaskStatus.completed:
        return 'Выполнена';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Низкий';
      case TaskPriority.normal:
        return 'Средний';
      case TaskPriority.high:
        return 'Высокий';
    }
  }
}

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? deadline;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.deadline,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? deadline,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Task(
      id: doc.id,
      projectId: data['projectId'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => TaskStatus.active,
      ),
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == data['priority'],
        orElse: () => TaskPriority.normal,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: data['deadline'] is Timestamp
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] is Timestamp
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
