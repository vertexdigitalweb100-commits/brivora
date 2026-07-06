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

  /// Копирует проект с измененными полями
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

  /// Конвертирует модель в JSON для Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'status': status.name,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? createdAt,
      'members': members,
    };
  }

  /// Создает модель из Firestore документа
  factory Project.fromFirestore(Map<String, dynamic> data) {
    return Project(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.active,
      ),
      ownerId: data['ownerId'] as String,
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
      updatedAt: data['updatedAt'] as DateTime?,
      members: List<String>.from(data['members'] as List? ?? []),
    );
  }

  @override
  String toString() => 'Project(id: $id, title: $title, ownerId: $ownerId)';
}

enum ProjectStatus {
  active,
  planning,
  completed,
  archived,
}

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
