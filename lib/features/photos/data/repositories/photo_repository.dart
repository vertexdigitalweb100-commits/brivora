import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/photo.dart';

class PhotoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  CollectionReference<Map<String, dynamic>> get _photosCollection =>
      _firestore.collection('photos');

  Future<void> pickAndUploadPhoto(String projectId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 90,
    );

    if (pickedFiles.isEmpty) return;

    const uuid = Uuid();

    for (final picked in pickedFiles) {
      final file = File(picked.path);

      final fileId = uuid.v4();

      final ref = _storage.ref().child(
        'projects/$projectId/photos/$fileId.jpg',
      );

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      final photo = Photo(
        id: '',
        projectId: projectId,
        ownerId: user.uid,
        imageUrl: url,
        fileName: '$fileId.jpg',
        createdAt: DateTime.now(),
      );

      await _photosCollection.add(photo.toFirestore());
    }
  }

  Stream<List<Photo>> getProjectPhotos(String projectId) {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _photosCollection
        .where('projectId', isEqualTo: projectId)
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Photo.fromFirestore(doc)).toList(),
        );
  }

  Future<void> deletePhoto(Photo photo) async {
    await _storage
        .ref()
        .child('projects/${photo.projectId}/photos/${photo.fileName}')
        .delete();

    await _photosCollection.doc(photo.id).delete();
  }
}
