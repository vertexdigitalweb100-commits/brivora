import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/repositories/photo_repository.dart';
import '../../domain/models/project_photo.dart';

class PhotosProvider extends ChangeNotifier {
  final PhotoRepository _repository = PhotoRepository();

  List<ProjectPhoto> _photos = [];
  bool _isLoading = false;
  String? _error;

  List<ProjectPhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPhotos(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _photos = await _repository.getProjectPhotos(projectId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadPhoto({
    required String projectId,
    required File imageFile,
  }) async {
    await _repository.uploadPhoto(projectId: projectId, imageFile: imageFile);

    await loadPhotos(projectId);
  }

  Future<void> deletePhoto(ProjectPhoto photo) async {
    await _repository.deletePhoto(photo);
    await loadPhotos(photo.projectId);
  }
}
