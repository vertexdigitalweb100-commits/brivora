import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  final String id;
  final String projectId;
  final String ownerId;
  final String imageUrl;
  final String fileName;
  final DateTime createdAt;
  final String caption;

  const Photo({
    required this.id,
    required this.projectId,
    required this.ownerId,
    required this.imageUrl,
    required this.fileName,
    required this.createdAt,
    this.caption = '',
  });

  Photo copyWith({
    String? id,
    String? projectId,
    String? ownerId,
    String? imageUrl,
    String? fileName,
    DateTime? createdAt,
    String? caption,
  }) {
    return Photo(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      ownerId: ownerId ?? this.ownerId,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'ownerId': ownerId,
      'imageUrl': imageUrl,
      'fileName': fileName,
      'createdAt': Timestamp.fromDate(createdAt),
      'caption': caption,
    };
  }

  factory Photo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Photo(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      fileName: data['fileName'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      caption: data['caption'] as String? ?? '',
    );
  }
}
