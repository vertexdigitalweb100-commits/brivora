import 'package:flutter/material.dart';

import '../../data/repositories/note_repository.dart';
import '../../domain/models/note.dart';

class NotesProvider extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _repository.getProjectNotes(projectId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNote(Note note) async {
    await _repository.createNote(note);
    await loadNotes(note.projectId);
  }

  Future<void> updateNote(Note note) async {
    await _repository.updateNote(note);
    await loadNotes(note.projectId);
  }

  Future<void> deleteNote(Note note) async {
    await _repository.deleteNote(note.id);
    await loadNotes(note.projectId);
  }
}
