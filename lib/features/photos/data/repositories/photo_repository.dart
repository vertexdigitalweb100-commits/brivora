import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/project_photo.dart';

class PhotoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _photosCollection =>
      _firestore.collection('photos');

  Future<void> uploadPhoto({
    required String projectId,
    required File imageFile,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    final fileId = const Uuid().v4();

    final ref = _storage.ref().child('projects/$projectId/photos/$fileId.jpg');

    await ref.putFile(imageFile);

    final imageUrl = await ref.getDownloadURL();

    final photo = ProjectPhoto(
      id: '',
      projectId: projectId,
      ownerId: user.uid,
      imageUrl: imageUrl,
      fileName: '$fileId.jpg',
      createdAt: DateTime.now(),
    );

    await _photosCollection.add(photo.toFirestore());
  }

  Future<List<ProjectPhoto>> getProjectPhotos(String projectId) async {
    final user = _auth.currentUser;

    if (user == null) return [];

    final snapshot = await _photosCollection
        .where('projectId', isEqualTo: projectId)
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ProjectPhoto.fromFirestore(doc)).toList();
  }

  Future<void> deletePhoto(ProjectPhoto photo) async {
    await _storage.refFromURL(photo.imageUrl).delete();

    await _photosCollection.doc(photo.id).delete();
  }
}
