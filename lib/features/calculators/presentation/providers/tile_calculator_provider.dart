import 'package:flutter/material.dart';
import '../../domain/models/tile_calculation.dart';
import '../../domain/services/tile_calculator_service.dart';

class TileCalculatorProvider extends ChangeNotifier {
  final TileCalculatorService _service = TileCalculatorService();

  String roomLength = '';
  String roomWidth = '';
  String tileLength = '';
  String tileWidth = '';
  String wastePercent = '10';

  TileCalculation? result;
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

  void setTileLength(String value) {
    tileLength = value;
    error = null;
    notifyListeners();
  }

  void setTileWidth(String value) {
    tileWidth = value;
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
    if (_isEmpty(roomLength)) {
      error = 'Введите длину помещения';
      return false;
    }
    if (_isEmpty(roomWidth)) {
      error = 'Введите ширину помещения';
      return false;
    }
    if (_isEmpty(tileLength)) {
      error = 'Введите длину плитки';
      return false;
    }
    if (_isEmpty(tileWidth)) {
      error = 'Введите ширину плитки';
      return false;
    }

    final roomLengthValue = _parseDouble(roomLength);
    final roomWidthValue = _parseDouble(roomWidth);
    final tileLengthValue = _parseDouble(tileLength);
    final tileWidthValue = _parseDouble(tileWidth);
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    if (roomLengthValue == null || roomLengthValue <= 0) {
      error = 'Значение должно быть больше 0';
      return false;
    }
    if (roomWidthValue == null || roomWidthValue <= 0) {
      error = 'Значение должно быть больше 0';
      return false;
    }
    if (tileLengthValue == null || tileLengthValue <= 0) {
      error = 'Значение должно быть больше 0';
      return false;
    }
    if (tileWidthValue == null || tileWidthValue <= 0) {
      error = 'Значение должно быть больше 0';
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
    final tileLengthValue = _parseDouble(tileLength)!;
    final tileWidthValue = _parseDouble(tileWidth)!;
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    result = _service.calculate(
      roomLengthCm: roomLengthValue,
      roomWidthCm: roomWidthValue,
      tileLengthCm: tileLengthValue,
      tileWidthCm: tileWidthValue,
      wastePercent: wasteValue,
    );

    notifyListeners();
  }

  void reset() {
    roomLength = '';
    roomWidth = '';
    tileLength = '';
    tileWidth = '';
    wastePercent = '10';
    result = null;
    error = null;
    notifyListeners();
  }
}
