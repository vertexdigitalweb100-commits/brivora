import 'package:flutter/material.dart';
import '../../domain/models/laminate_calculation.dart';
import '../../domain/services/laminate_calculator_service.dart';

class LaminateCalculatorProvider extends ChangeNotifier {
  final LaminateCalculatorService _service = LaminateCalculatorService();

  String roomLength = '';
  String roomWidth = '';
  String panelLength = '';
  String panelWidth = '';
  String panelsPerPack = '';
  String wastePercent = '10';

  LaminateCalculation? result;
  String? error;

  void setRoomLength(String value) {
    roomLength = value;
    error = null;
    notifyListeners();
  }

  void setRoomWidth(String value) {
    roomWidth = value;
    error = null;
    notifyListeners();
  }

  void setPanelLength(String value) {
    panelLength = value;
    error = null;
    notifyListeners();
  }

  void setPanelWidth(String value) {
    panelWidth = value;
    error = null;
    notifyListeners();
  }

  void setPanelsPerPack(String value) {
    panelsPerPack = value;
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

  int? _parseInt(String value) {
    return int.tryParse(value.trim());
  }

  bool _validateFields() {
    if (_isEmpty(roomLength)) {
      error = 'Введите длину комнаты';
      return false;
    }
    if (_isEmpty(roomWidth)) {
      error = 'Введите ширину комнаты';
      return false;
    }
    if (_isEmpty(panelLength)) {
      error = 'Введите длину панели';
      return false;
    }
    if (_isEmpty(panelWidth)) {
      error = 'Введите ширину панели';
      return false;
    }
    if (_isEmpty(panelsPerPack)) {
      error = 'Введите количество панелей в упаковке';
      return false;
    }

    final roomLengthValue = _parseDouble(roomLength);
    final roomWidthValue = _parseDouble(roomWidth);
    final panelLengthValue = _parseDouble(panelLength);
    final panelWidthValue = _parseDouble(panelWidth);
    final panelsPerPackValue = _parseInt(panelsPerPack);
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    if (roomLengthValue == null || roomLengthValue <= 0) {
      error = 'Длина комнаты должна быть больше 0';
      return false;
    }
    if (roomWidthValue == null || roomWidthValue <= 0) {
      error = 'Ширина комнаты должна быть больше 0';
      return false;
    }
    if (panelLengthValue == null || panelLengthValue <= 0) {
      error = 'Длина панели должна быть больше 0';
      return false;
    }
    if (panelWidthValue == null || panelWidthValue <= 0) {
      error = 'Ширина панели должна быть больше 0';
      return false;
    }
    if (panelsPerPackValue == null || panelsPerPackValue <= 0) {
      error = 'Панелей в упаковке должно быть целым числом больше 0';
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

    final roomLengthValue = _parseDouble(roomLength)!;
    final roomWidthValue = _parseDouble(roomWidth)!;
    final panelLengthValue = _parseDouble(panelLength)!;
    final panelWidthValue = _parseDouble(panelWidth)!;
    final panelsPerPackValue = _parseInt(panelsPerPack)!;
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    result = _service.calculate(
      roomLength: roomLengthValue,
      roomWidth: roomWidthValue,
      panelLength: panelLengthValue,
      panelWidth: panelWidthValue,
      panelsPerPack: panelsPerPackValue,
      wastePercent: wasteValue,
    );

    notifyListeners();
  }

  void reset() {
    roomLength = '';
    roomWidth = '';
    panelLength = '';
    panelWidth = '';
    panelsPerPack = '';
    wastePercent = '10';
    result = null;
    error = null;
    notifyListeners();
  }
}
