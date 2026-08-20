import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/models/user_profile.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  Future<UserProfile> getUserProfile() async {
    final doc = _userDoc;
    if (doc == null) return const UserProfile();

    final snapshot = await doc.get();
    if (!snapshot.exists) return const UserProfile();

    return UserProfile.fromFirestore(snapshot.data());
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final doc = _userDoc;
    final user = _auth.currentUser;

    if (doc == null || user == null) {
      throw Exception('Пользователь не авторизован');
    }

    await doc.set(profile.toFirestore(), SetOptions(merge: true));

    // Держим имя Firebase Auth синхронизированным с профилем,
    // чтобы приветствие на Главной тоже было реальным.
    final fullName = profile.fullName;
    if (fullName.isNotEmpty && user.displayName != fullName) {
      try {
        await user.updateDisplayName(fullName);
      } catch (_) {
        // Данные профиля уже сохранены в Firestore; ошибка Auth
        // не должна показывать пользователю, что сохранение профиля не удалось.
      }
    }
  }

  Future<String?> pickAndUploadAvatar(ImageSource source) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (picked == null) return null;

    final ref = _storage.ref().child('users/${user.uid}/avatar.jpg');
    await ref.putFile(
      File(picked.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();
    await _userDoc!.set({
      'avatarUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return url;
  }

  Future<void> deleteAvatar() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    final ref = _storage.ref().child('users/${user.uid}/avatar.jpg');
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }

    await _userDoc!.set({
      'avatarUrl': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
