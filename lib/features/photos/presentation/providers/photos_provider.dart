import 'package:flutter/material.dart';

import '../../data/repositories/photo_repository.dart';
import '../../domain/models/photo.dart';

class PhotosProvider extends ChangeNotifier {
  final PhotoRepository _repository = PhotoRepository();

  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _error;

  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> uploadPhoto(String projectId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.pickAndUploadPhoto(projectId);

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Stream<List<Photo>> getPhotos(String projectId) {
    return _repository.getProjectPhotos(projectId);
  }

  Future<void> deletePhoto(Photo photo) async {
    await _repository.deletePhoto(photo);
  }
}
