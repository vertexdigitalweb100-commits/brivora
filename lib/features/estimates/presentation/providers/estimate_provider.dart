import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/estimate_repository.dart';
import '../../domain/models/estimate_item.dart';

class EstimateProvider extends ChangeNotifier {
  final EstimateRepository repository = EstimateRepository();

  List<EstimateItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  StreamSubscription<List<EstimateItem>>? _subscription;
  String? _projectId;

  List<EstimateItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<EstimateItem> get filteredItems {
    if (_selectedCategory == 'all') {
      return items;
    }
    return items.where((item) => item.category == _selectedCategory).toList();
  }

  List<EstimateItem> categoryItems(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  double get totalMaterials =>
      categoryItems('material').fold(0, (sum, item) => sum + item.totalPrice);

  double get totalLabor =>
      categoryItems('labor').fold(0, (sum, item) => sum + item.totalPrice);

  double get totalDelivery =>
      categoryItems('delivery').fold(0, (sum, item) => sum + item.totalPrice);

  double get totalTools =>
      categoryItems('tools').fold(0, (sum, item) => sum + item.totalPrice);

  double get totalOther =>
      categoryItems('other').fold(0, (sum, item) => sum + item.totalPrice);

  double get grandTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void listenToProjectEstimates(String projectId) {
    if (_projectId == projectId) {
      return;
    }

    _projectId = projectId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = repository
        .getProjectEstimatesStream(projectId)
        .listen(
          (items) {
            _items = items;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Ошибка загрузки сметы: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addEstimateItem(EstimateItem item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await repository.createEstimateItem(item);
    } catch (error) {
      _error = 'Ошибка при создании позиции: $error';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEstimateItem(EstimateItem item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await repository.updateEstimateItem(item);
    } catch (error) {
      _error = 'Ошибка при сохранении позиции: $error';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEstimateItem(String itemId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await repository.deleteEstimateItem(itemId);
    } catch (error) {
      _error = 'Ошибка при удалении позиции: $error';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _projectId = null;
    _items = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
