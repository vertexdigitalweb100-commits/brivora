import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/user_profile.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

    if (doc == null) {
      throw Exception('Пользователь не авторизован');
    }

    await doc.set(profile.toFirestore(), SetOptions(merge: true));
  }
}
