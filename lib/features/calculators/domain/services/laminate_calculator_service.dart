import '../models/laminate_calculation.dart';

class LaminateCalculatorService {
  LaminateCalculation calculate({
    required double roomLength,
    required double roomWidth,
    required double panelLength,
    required double panelWidth,
    required int panelsPerPack,
    double wastePercent = 10,
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
    if (panelLength <= 0) {
      throw ArgumentError.value(
        panelLength,
        'panelLength',
        'Длина панели должна быть больше 0',
      );
    }
    if (panelWidth <= 0) {
      throw ArgumentError.value(
        panelWidth,
        'panelWidth',
        'Ширина панели должна быть больше 0',
      );
    }
    if (panelsPerPack <= 0) {
      throw ArgumentError.value(
        panelsPerPack,
        'panelsPerPack',
        'Панелей в упаковке должно быть больше 0',
      );
    }
    if (wastePercent < 0) {
      throw ArgumentError.value(
        wastePercent,
        'wastePercent',
        'Запас не может быть отрицательным',
      );
    }

    final roomArea = roomLength * roomWidth;
    final panelArea = panelLength * panelWidth;
    if (panelArea <= 0) {
      throw ArgumentError.value(
        panelArea,
        'panelArea',
        'Площадь панели должна быть больше 0',
      );
    }

    final panelsWithoutWaste = roomArea / panelArea;
    final panelsWithoutWasteRounded = panelsWithoutWaste.ceil();
    final panelsWithWaste = (panelsWithoutWaste * (1 + wastePercent / 100))
        .ceil();
    final packs = ((panelsWithWaste + panelsPerPack - 1) ~/ panelsPerPack);

    return LaminateCalculation(
      roomLength: roomLength,
      roomWidth: roomWidth,
      panelLength: panelLength,
      panelWidth: panelWidth,
      panelsPerPack: panelsPerPack,
      wastePercent: wastePercent,
      roomArea: roomArea,
      panelArea: panelArea,
      panelsWithoutWaste: panelsWithoutWasteRounded,
      panelsWithWaste: panelsWithWaste,
      packs: packs,
    );
  }
}
