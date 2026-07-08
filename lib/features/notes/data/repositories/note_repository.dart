import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/note.dart';

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('notes');

  Future<void> createNote(Note note) async {
    await _notesCollection.add(note.toFirestore());
  }

  Future<void> updateNote(Note note) async {
    await _notesCollection.doc(note.id).update(note.toFirestore());
  }

  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }

  Future<List<Note>> getProjectNotes(String projectId) async {
    final user = _auth.currentUser;

    if (user == null) return [];

    final snapshot = await _notesCollection
        .where('projectId', isEqualTo: projectId)
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
  }

  Stream<List<Note>> getProjectNotesStream(String projectId) {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _notesCollection
        .where('projectId', isEqualTo: projectId)
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList(),
        );
  }
}
