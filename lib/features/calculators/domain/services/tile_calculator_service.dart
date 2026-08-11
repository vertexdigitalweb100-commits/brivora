import '../models/tile_calculation.dart';

class TileCalculatorService {
  TileCalculation calculate({
    required double roomLengthCm,
    required double roomWidthCm,
    required double tileLengthCm,
    required double tileWidthCm,
    double wastePercent = 10,
    int? tilesPerBox,
  }) {
    final roomLengthMeters = roomLengthCm / 100;
    final roomWidthMeters = roomWidthCm / 100;
    final tileLengthMeters = tileLengthCm / 100;
    final tileWidthMeters = tileWidthCm / 100;

    final roomArea = roomLengthMeters * roomWidthMeters;
    final tileArea = tileLengthMeters * tileWidthMeters;

    if (tileArea <= 0) {
      throw ArgumentError.value(
        tileArea,
        'tileArea',
        'Площадь плитки должна быть больше 0',
      );
    }

    final baseTiles = roomArea / tileArea;
    final tilesWithoutWaste = baseTiles.ceil();
    final tilesWithWaste = (baseTiles * (1 + wastePercent / 100)).ceil();
    final totalCoveredArea = tilesWithWaste * tileArea;

    final boxes = tilesPerBox != null && tilesPerBox > 0
        ? ((tilesWithWaste + tilesPerBox - 1) ~/ tilesPerBox)
        : null;

    return TileCalculation(
      roomLength: roomLengthCm,
      roomWidth: roomWidthCm,
      tileLength: tileLengthCm,
      tileWidth: tileWidthCm,
      wastePercent: wastePercent,
      roomArea: roomArea,
      tileArea: tileArea,
      tilesWithoutWaste: tilesWithoutWaste,
      tilesWithWaste: tilesWithWaste,
      totalCoveredArea: totalCoveredArea,
      tilesPerBox: tilesPerBox,
      boxes: boxes,
    );
  }
}
