import 'package:flutter/material.dart';
import '../../domain/models/wallpaper_calculation.dart';
import '../../domain/services/wallpaper_calculator_service.dart';

class WallpaperCalculatorProvider extends ChangeNotifier {
  final WallpaperCalculatorService _service = WallpaperCalculatorService();

  String roomLength = '';
  String roomWidth = '';
  String ceilingHeight = '';
  String rollWidth = '';
  String rollLength = '';
  String doorCount = '0';
  String doorWidth = '0';
  String windowCount = '0';
  String windowWidth = '0';
  String windowHeight = '0';
  String wastePercent = '10';

  WallpaperCalculation? result;
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

  void setCeilingHeight(String value) {
    ceilingHeight = value;
    error = null;
    notifyListeners();
  }

  void setRollWidth(String value) {
    rollWidth = value;
    error = null;
    notifyListeners();
  }

  void setRollLength(String value) {
    rollLength = value;
    error = null;
    notifyListeners();
  }

  void setDoorCount(String value) {
    doorCount = value;
    error = null;
    notifyListeners();
  }

  void setDoorWidth(String value) {
    doorWidth = value;
    error = null;
    notifyListeners();
  }

  void setWindowCount(String value) {
    windowCount = value;
    error = null;
    notifyListeners();
  }

  void setWindowWidth(String value) {
    windowWidth = value;
    error = null;
    notifyListeners();
  }

  void setWindowHeight(String value) {
    windowHeight = value;
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
    if (_isEmpty(ceilingHeight)) {
      error = 'Введите высоту потолка';
      return false;
    }
    if (_isEmpty(rollWidth)) {
      error = 'Введите ширину рулона';
      return false;
    }
    if (_isEmpty(rollLength)) {
      error = 'Введите длину рулона';
      return false;
    }
    if (_isEmpty(doorCount)) {
      error = 'Введите количество дверей';
      return false;
    }
    if (_isEmpty(doorWidth)) {
      error = 'Введите ширину двери';
      return false;
    }
    if (_isEmpty(windowCount)) {
      error = 'Введите количество окон';
      return false;
    }
    if (_isEmpty(windowWidth)) {
      error = 'Введите ширину окна';
      return false;
    }
    if (_isEmpty(windowHeight)) {
      error = 'Введите высоту окна';
      return false;
    }

    final roomLengthValue = _parseDouble(roomLength);
    final roomWidthValue = _parseDouble(roomWidth);
    final ceilingHeightValue = _parseDouble(ceilingHeight);
    final rollWidthValue = _parseDouble(rollWidth);
    final rollLengthValue = _parseDouble(rollLength);
    final doorCountValue = _parseInt(doorCount);
    final doorWidthValue = _parseDouble(doorWidth);
    final windowCountValue = _parseInt(windowCount);
    final windowWidthValue = _parseDouble(windowWidth);
    final windowHeightValue = _parseDouble(windowHeight);
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    if (roomLengthValue == null || roomLengthValue <= 0) {
      error = 'Длина комнаты должна быть больше 0';
      return false;
    }
    if (roomWidthValue == null || roomWidthValue <= 0) {
      error = 'Ширина комнаты должна быть больше 0';
      return false;
    }
    if (ceilingHeightValue == null || ceilingHeightValue <= 0) {
      error = 'Высота потолка должна быть больше 0';
      return false;
    }
    if (rollWidthValue == null || rollWidthValue <= 0) {
      error = 'Ширина рулона должна быть больше 0';
      return false;
    }
    if (rollLengthValue == null || rollLengthValue <= 0) {
      error = 'Длина рулона должна быть больше 0';
      return false;
    }
    if (doorCountValue == null || doorCountValue < 0) {
      error = 'Количество дверей должно быть целым числом 0 или больше';
      return false;
    }
    if (doorWidthValue == null || doorWidthValue < 0) {
      error = 'Ширина двери должна быть неотрицательной';
      return false;
    }
    if (windowCountValue == null || windowCountValue < 0) {
      error = 'Количество окон должно быть целым числом 0 или больше';
      return false;
    }
    if (windowWidthValue == null || windowWidthValue < 0) {
      error = 'Ширина окна должна быть неотрицательной';
      return false;
    }
    if (windowHeightValue == null || windowHeightValue < 0) {
      error = 'Высота окна должна быть неотрицательной';
      return false;
    }
    if (wasteValue < 0) {
      error = 'Запас не может быть отрицательным';
      return false;
    }
    if (ceilingHeightValue > rollLengthValue) {
      error = 'Высота потолка не может быть больше длины рулона';
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
    final ceilingHeightValue = _parseDouble(ceilingHeight)!;
    final rollWidthValue = _parseDouble(rollWidth)!;
    final rollLengthValue = _parseDouble(rollLength)!;
    final doorCountValue = _parseInt(doorCount)!;
    final doorWidthValue = _parseDouble(doorWidth)!;
    final windowCountValue = _parseInt(windowCount)!;
    final windowWidthValue = _parseDouble(windowWidth)!;
    final windowHeightValue = _parseDouble(windowHeight)!;
    final wasteValue = _parseDouble(wastePercent) ?? 10;

    result = _service.calculate(
      roomLength: roomLengthValue,
      roomWidth: roomWidthValue,
      ceilingHeight: ceilingHeightValue,
      rollWidth: rollWidthValue,
      rollLength: rollLengthValue,
      doorCount: doorCountValue,
      doorWidth: doorWidthValue,
      windowCount: windowCountValue,
      windowWidth: windowWidthValue,
      windowHeight: windowHeightValue,
      wastePercent: wasteValue,
    );

    notifyListeners();
  }

  void reset() {
    roomLength = '';
    roomWidth = '';
    ceilingHeight = '';
    rollWidth = '';
    rollLength = '';
    doorCount = '0';
    doorWidth = '0';
    windowCount = '0';
    windowWidth = '0';
    windowHeight = '0';
    wastePercent = '10';
    result = null;
    error = null;
    notifyListeners();
  }
}
