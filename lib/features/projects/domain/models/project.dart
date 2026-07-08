import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final double progress;
  final ProjectStatus status;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> members;

  Project({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.createdAt,
    this.description = '',
    this.progress = 0.0,
    this.status = ProjectStatus.active,
    this.updatedAt,
    this.members = const [],
  });

  Project copyWith({
    String? id,
    String? title,
    String? description,
    double? progress,
    ProjectStatus? status,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? members,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'status': status.name,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? createdAt),
      'members': members,
    };
  }

  factory Project.fromFirestore(Map<String, dynamic> data) {
    return Project(
      id: data['id'] ?? '',

      title: data['title'] ?? '',

      description: data['description'] ?? '',

      progress: (data['progress'] ?? 0).toDouble(),

      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],

        orElse: () => ProjectStatus.active,
      ),

      ownerId: data['ownerId'] ?? '',

      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,

      members: List<String>.from(data['members'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, title: $title, ownerId: $ownerId)';
  }
}

enum ProjectStatus { active, planning, completed, archived }

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.active:
        return 'Активный';

      case ProjectStatus.planning:
        return 'Планирование';

      case ProjectStatus.completed:
        return 'Завершен';

      case ProjectStatus.archived:
        return 'Архив';
    }
  }

  String get shortName {
    switch (this) {
      case ProjectStatus.active:
        return 'Активный';

      case ProjectStatus.planning:
        return 'В процессе';

      case ProjectStatus.completed:
        return 'Завершен';

      case ProjectStatus.archived:
        return 'Архив';
    }
  }
}
