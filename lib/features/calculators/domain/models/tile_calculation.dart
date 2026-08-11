class TileCalculation {
  final double roomLength;
  final double roomWidth;
  final double tileLength;
  final double tileWidth;
  final double wastePercent;
  final double roomArea;
  final double tileArea;
  final int tilesWithoutWaste;
  final int tilesWithWaste;
  final int? tilesPerBox;
  final int? boxes;
  final double totalCoveredArea;

  TileCalculation({
    required this.roomLength,
    required this.roomWidth,
    required this.tileLength,
    required this.tileWidth,
    required this.wastePercent,
    required this.roomArea,
    required this.tileArea,
    required this.tilesWithoutWaste,
    required this.tilesWithWaste,
    required this.totalCoveredArea,
    this.tilesPerBox,
    this.boxes,
  });
}
