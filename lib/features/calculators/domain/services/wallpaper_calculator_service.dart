import '../models/wallpaper_calculation.dart';

class WallpaperCalculatorService {
  WallpaperCalculation calculate({
    required double roomLength,
    required double roomWidth,
    required double ceilingHeight,
    required double rollWidth,
    required double rollLength,
    required int doorCount,
    required double doorWidth,
    required int windowCount,
    required double windowWidth,
    required double windowHeight,
    double wastePercent = 10,
  }) {
    if (roomLength <= 0) {
      throw ArgumentError.value(
        roomLength,
        'roomLength',
        'Длина помещения должна быть больше 0',
      );
    }
    if (roomWidth <= 0) {
      throw ArgumentError.value(
        roomWidth,
        'roomWidth',
        'Ширина помещения должна быть больше 0',
      );
    }
    if (ceilingHeight <= 0) {
      throw ArgumentError.value(
        ceilingHeight,
        'ceilingHeight',
        'Высота потолка должна быть больше 0',
      );
    }
    if (rollWidth <= 0) {
      throw ArgumentError.value(
        rollWidth,
        'rollWidth',
        'Ширина рулона должна быть больше 0',
      );
    }
    if (rollLength <= 0) {
      throw ArgumentError.value(
        rollLength,
        'rollLength',
        'Длина рулона должна быть больше 0',
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
    if (wastePercent < 0) {
      throw ArgumentError.value(
        wastePercent,
        'wastePercent',
        'Запас не может быть отрицательным',
      );
    }

    final perimeter = 2 * (roomLength + roomWidth);
    final wallArea = perimeter * ceilingHeight;
    final doorArea = doorCount * doorWidth * ceilingHeight;
    final windowArea = windowCount * windowWidth * windowHeight;
    final usableWallArea = wallArea - doorArea - windowArea;
    final rollArea = rollWidth * rollLength;
    final requiredArea = usableWallArea * (1 + wastePercent / 100);

    final stripsPerRoll = rollLength ~/ ceilingHeight;
    final requiredStrips = (perimeter / rollWidth).ceil();
    final rolls = (requiredStrips / (stripsPerRoll > 0 ? stripsPerRoll : 1))
        .ceil();
    final rollsWithWaste = (rolls * (1 + wastePercent / 100)).ceil();

    return WallpaperCalculation(
      roomLength: roomLength,
      roomWidth: roomWidth,
      ceilingHeight: ceilingHeight,
      rollWidth: rollWidth,
      rollLength: rollLength,
      doorCount: doorCount,
      doorWidth: doorWidth,
      windowCount: windowCount,
      windowWidth: windowWidth,
      windowHeight: windowHeight,
      wastePercent: wastePercent,
      perimeter: perimeter,
      wallArea: wallArea,
      doorArea: doorArea,
      windowArea: windowArea,
      usableWallArea: usableWallArea,
      rollArea: rollArea,
      stripsPerRoll: stripsPerRoll,
      requiredStrips: requiredStrips,
      rolls: rolls,
      rollsWithWaste: rollsWithWaste,
      requiredArea: requiredArea,
    );
  }
}
