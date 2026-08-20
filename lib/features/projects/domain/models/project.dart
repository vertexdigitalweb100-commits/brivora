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
  final String? coverImageUrl;

  const Project({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.createdAt,
    this.description = '',
    this.progress = 0.0,
    this.status = ProjectStatus.active,
    this.updatedAt,
    this.members = const [],
    this.coverImageUrl,
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
    String? coverImageUrl,
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
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
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
      'coverImageUrl': coverImageUrl,
    };
  }

  factory Project.fromFirestore(
    Map<String, dynamic> data, {
    String? documentId,
  }) {
    final rawId = data['id'];

    final String projectId = documentId != null && documentId.trim().isNotEmpty
        ? documentId
        : rawId is String && rawId.trim().isNotEmpty
        ? rawId
        : '';

    final rawTitle = data['title'];
    final rawDescription = data['description'];
    final rawOwnerId = data['ownerId'];
    final rawProgress = data['progress'];
    final rawStatus = data['status'];
    final rawMembers = data['members'];
    final rawCover = data['coverImageUrl'];

    double parsedProgress = 0.0;

    if (rawProgress is num) {
      parsedProgress = rawProgress.toDouble();
    } else if (rawProgress is String) {
      parsedProgress = double.tryParse(rawProgress) ?? 0.0;
    }

    parsedProgress = parsedProgress.clamp(0.0, 1.0);

    ProjectStatus parsedStatus = ProjectStatus.active;

    if (rawStatus is String) {
      parsedStatus = ProjectStatus.values.firstWhere(
        (status) => status.name == rawStatus,
        orElse: () => ProjectStatus.active,
      );
    }

    DateTime parsedCreatedAt = DateTime.now();

    final createdValue = data['createdAt'];

    if (createdValue is Timestamp) {
      parsedCreatedAt = createdValue.toDate();
    } else if (createdValue is DateTime) {
      parsedCreatedAt = createdValue;
    } else if (createdValue is String) {
      parsedCreatedAt = DateTime.tryParse(createdValue) ?? DateTime.now();
    }

    DateTime? parsedUpdatedAt;

    final updatedValue = data['updatedAt'];

    if (updatedValue is Timestamp) {
      parsedUpdatedAt = updatedValue.toDate();
    } else if (updatedValue is DateTime) {
      parsedUpdatedAt = updatedValue;
    } else if (updatedValue is String) {
      parsedUpdatedAt = DateTime.tryParse(updatedValue);
    }

    List<String> parsedMembers = const [];

    if (rawMembers is List) {
      parsedMembers = rawMembers
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toList();
    }

    String? parsedCoverImageUrl;

    if (rawCover is String && rawCover.trim().isNotEmpty) {
      parsedCoverImageUrl = rawCover.trim();
    }

    return Project(
      id: projectId,
      title: rawTitle is String ? rawTitle : '',
      description: rawDescription is String ? rawDescription : '',
      progress: parsedProgress,
      status: parsedStatus,
      ownerId: rawOwnerId is String ? rawOwnerId : '',
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      members: parsedMembers,
      coverImageUrl: parsedCoverImageUrl,
    );
  }

  @override
  String toString() {
    return 'Project('
        'id: $id, '
        'title: $title, '
        'ownerId: $ownerId, '
        'status: ${status.name}, '
        'progress: $progress'
        ')';
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
        return 'Завершён';

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
        return 'Завершён';

      case ProjectStatus.archived:
        return 'Архив';
    }
  }
}
