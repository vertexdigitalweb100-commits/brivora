import 'package:flutter/material.dart';
import '../../domain/models/concrete_calculation.dart';
import '../../domain/services/concrete_calculator_service.dart';

class ConcreteCalculatorProvider extends ChangeNotifier {
  final ConcreteCalculatorService _service = ConcreteCalculatorService();

  String length = '';
  String width = '';
  String thickness = '';
  String constructionType = 'Пол';
  String wastePercent = '10';

  ConcreteCalculation? result;
  String? error;

  void setLength(String value) {
    length = value;
    error = null;
    notifyListeners();
  }

  void setWidth(String value) {
    width = value;
    error = null;
    notifyListeners();
  }

  void setThickness(String value) {
    thickness = value;
    error = null;
    notifyListeners();
  }

  void setConstructionType(String value) {
    constructionType = value;
    error = null;
    notifyListeners();
  }

  void setWastePercent(String value) {
    wastePercent = value;
    error = null;
    notifyListeners();
  }

  bool _isEmpty(String value) {
    return value.trim().isEmpty;
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  bool _validateFields() {
    if (_isEmpty(length)) {
      error = 'Введите длину';
      return false;
    }
    if (_isEmpty(width)) {
      error = 'Введите ширину';
      return false;
    }
    if (_isEmpty(thickness)) {
      error = 'Введите толщину';
      return false;
    }

    final lengthValue = _parseDouble(length);
    final widthValue = _parseDouble(width);
    final thicknessValue = _parseDouble(thickness);
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    if (lengthValue == null || lengthValue <= 0) {
      error = 'Длина должна быть больше 0';
      return false;
    }
    if (widthValue == null || widthValue <= 0) {
      error = 'Ширина должна быть больше 0';
      return false;
    }
    if (thicknessValue == null || thicknessValue <= 0) {
      error = 'Толщина должна быть больше 0';
      return false;
    }
    if (wasteValue < 0) {
      error = 'Запас не может быть отрицательным';
      return false;
    }

    error = null;
    return true;
  }

  void calculate() {
    if (!_validateFields()) {
      result = null;
      notifyListeners();
      return;
    }

    final lengthValue = _parseDouble(length)!;
    final widthValue = _parseDouble(width)!;
    final thicknessValue = _parseDouble(thickness)!;
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    result = _service.calculate(
      length: lengthValue,
      width: widthValue,
      thicknessCm: thicknessValue,
      constructionType: constructionType,
      wastePercent: wasteValue,
    );

    notifyListeners();
  }

  void reset() {
    length = '';
    width = '';
    thickness = '';
    constructionType = 'Пол';
    wastePercent = '10';
    result = null;
    error = null;
    notifyListeners();
  }
}
