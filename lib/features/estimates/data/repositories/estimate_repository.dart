import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/estimate_item.dart';

class EstimateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _estimatesCollection =>
      _firestore.collection('estimates');

  Future<EstimateItem> createEstimateItem(EstimateItem item) async {
    final doc = _estimatesCollection.doc();

    final now = DateTime.now();

    final newItem = item.copyWith(
      id: doc.id,
      createdAt: now,
      updatedAt: now,
      totalPrice: item.quantity * item.unitPrice,
    );

    final data = newItem.toFirestore();

    final user = _auth.currentUser;

    if (user != null) {
      data['ownerId'] = user.uid;
    }

    await doc.set(data);

    return newItem;
  }

  Future<void> updateEstimateItem(EstimateItem item) async {
    final updatedItem = item.copyWith(
      updatedAt: DateTime.now(),
      totalPrice: item.quantity * item.unitPrice,
    );

    final data = updatedItem.toFirestore();

    final user = _auth.currentUser;

    if (user != null) {
      data['ownerId'] = user.uid;
    }

    await _estimatesCollection.doc(item.id).set(data);
  }

  Future<void> deleteEstimateItem(String itemId) async {
    await _estimatesCollection.doc(itemId).delete();
  }

  Stream<List<EstimateItem>> getProjectEstimatesStream(String projectId) {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _estimatesCollection
        .where('projectId', isEqualTo: projectId)
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => EstimateItem.fromFirestore(doc))
              .toList();

          // Сортируем уже на стороне приложения,
          // чтобы Firestore не требовал composite index.
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return items;
        });
  }
}
