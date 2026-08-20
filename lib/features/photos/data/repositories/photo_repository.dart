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

    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (pickedFiles.isEmpty) return;

    // Все выбранные фотографии загружаются параллельно.
    await Future.wait(
      pickedFiles.map(
        (picked) => _uploadFile(File(picked.path), projectId, user.uid),
      ),
    );
  }

  Future<void> takeAndUploadPhoto(String projectId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (picked == null) return;

    await _uploadFile(File(picked.path), projectId, user.uid);
  }

  Future<void> _uploadFile(File file, String projectId, String ownerId) async {
    const uuid = Uuid();

    final fileId = uuid.v4();
    final fileName = '$fileId.jpg';

    final ref = _storage.ref().child('projects/$projectId/photos/$fileName');

    await ref.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=31536000',
      ),
    );

    final url = await ref.getDownloadURL();

    final photo = Photo(
      id: '',
      projectId: projectId,
      ownerId: ownerId,
      imageUrl: url,
      fileName: fileName,
      createdAt: DateTime.now(),
      caption: '',
    );

    await _photosCollection.add(photo.toFirestore());
  }

  Future<void> updatePhotoCaption(String photoId, String caption) async {
    await _photosCollection.doc(photoId).update({'caption': caption});
  }

  Stream<List<Photo>> getProjectPhotos(String projectId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

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

  Future<int> getUserPhotoCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final snapshot = await _photosCollection
        .where('ownerId', isEqualTo: user.uid)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<void> deletePhoto(Photo photo) async {
    await _storage
        .ref()
        .child('projects/${photo.projectId}/photos/${photo.fileName}')
        .delete();

    await _photosCollection.doc(photo.id).delete();
  }
}
