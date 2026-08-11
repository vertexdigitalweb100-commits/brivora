import '../models/paint_calculation.dart';

class PaintCalculatorService {
  PaintCalculation calculate({
    required double roomLength,
    required double roomWidth,
    required double ceilingHeight,
    required int doorCount,
    required double doorWidth,
    required double doorHeight,
    required int windowCount,
    required double windowWidth,
    required double windowHeight,
    required int coats,
    required double coverage,
    double wastePercent = 10,
    required bool includeCeiling,
  }) {
    if (roomLength <= 0) {
      throw ArgumentError.value(
        roomLength,
        'roomLength',
        'Длина комнаты должна быть больше 0',
      );
    }
    if (roomWidth <= 0) {
      throw ArgumentError.value(
        roomWidth,
        'roomWidth',
        'Ширина комнаты должна быть больше 0',
      );
    }
    if (ceilingHeight <= 0) {
      throw ArgumentError.value(
        ceilingHeight,
        'ceilingHeight',
        'Высота потолка должна быть больше 0',
      );
    }
    if (doorCount < 0) {
      throw ArgumentError.value(
        doorCount,
        'doorCount',
        'Количество дверей не может быть отрицательным',
      );
    }
    if (doorWidth < 0) {
      throw ArgumentError.value(
        doorWidth,
        'doorWidth',
        'Ширина двери не может быть отрицательной',
      );
    }
    if (doorHeight < 0) {
      throw ArgumentError.value(
        doorHeight,
        'doorHeight',
        'Высота двери не может быть отрицательной',
      );
    }
    if (windowCount < 0) {
      throw ArgumentError.value(
        windowCount,
        'windowCount',
        'Количество окон не может быть отрицательным',
      );
    }
    if (windowWidth < 0) {
      throw ArgumentError.value(
        windowWidth,
        'windowWidth',
        'Ширина окна не может быть отрицательной',
      );
    }
    if (windowHeight < 0) {
      throw ArgumentError.value(
        windowHeight,
        'windowHeight',
        'Высота окна не может быть отрицательной',
      );
    }
    if (coats <= 0) {
      throw ArgumentError.value(
        coats,
        'coats',
        'Количество слоёв должно быть больше 0',
      );
    }
    if (coverage <= 0) {
      throw ArgumentError.value(
        coverage,
        'coverage',
        'Расход краски должен быть больше 0',
      );
    }
    if (wastePercent < 0) {
      throw ArgumentError.value(
        wastePercent,
        'wastePercent',
        'Запас не может быть отрицательным',
      );
    }

    final wallArea = 2 * (roomLength + roomWidth) * ceilingHeight;
    final doorArea = doorCount * doorWidth * doorHeight;
    final windowArea = windowCount * windowWidth * windowHeight;
    final usableWallArea = wallArea - doorArea - windowArea;
    final ceilingArea = includeCeiling ? roomLength * roomWidth : 0.0;
    final totalArea = usableWallArea + ceilingArea;
    final paintArea = totalArea * coats;
    final requiredArea = paintArea * (1 + wastePercent / 100);
    final paintLiters = requiredArea / coverage;
    final paintLitersRounded = paintLiters.ceilToDouble();

    return PaintCalculation(
      roomLength: roomLength,
      roomWidth: roomWidth,
      ceilingHeight: ceilingHeight,
      doorCount: doorCount,
      doorWidth: doorWidth,
      doorHeight: doorHeight,
      windowCount: windowCount,
      windowWidth: windowWidth,
      windowHeight: windowHeight,
      coats: coats,
      coverage: coverage,
      wastePercent: wastePercent,
      paintScope: includeCeiling ? 'Стены + потолок' : 'Только стены',
      wallArea: wallArea,
      ceilingArea: ceilingArea,
      doorArea: doorArea,
      windowArea: windowArea,
      usableWallArea: usableWallArea,
      totalArea: totalArea,
      paintArea: paintArea,
      requiredArea: requiredArea,
      paintLiters: paintLiters,
      paintLitersRounded: paintLitersRounded,
    );
  }
}
