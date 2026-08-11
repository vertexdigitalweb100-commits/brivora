class WallpaperCalculation {
  final double roomLength;
  final double roomWidth;
  final double ceilingHeight;
  final double rollWidth;
  final double rollLength;
  final int doorCount;
  final double doorWidth;
  final int windowCount;
  final double windowWidth;
  final double windowHeight;
  final double wastePercent;
  final double perimeter;
  final double wallArea;
  final double doorArea;
  final double windowArea;
  final double usableWallArea;
  final double rollArea;
  final int stripsPerRoll;
  final int requiredStrips;
  final int rolls;
  final int rollsWithWaste;
  final double requiredArea;

  WallpaperCalculation({
    required this.roomLength,
    required this.roomWidth,
    required this.ceilingHeight,
    required this.rollWidth,
    required this.rollLength,
    required this.doorCount,
    required this.doorWidth,
    required this.windowCount,
    required this.windowWidth,
    required this.windowHeight,
    required this.wastePercent,
    required this.perimeter,
    required this.wallArea,
    required this.doorArea,
    required this.windowArea,
    required this.usableWallArea,
    required this.rollArea,
    required this.stripsPerRoll,
    required this.requiredStrips,
    required this.rolls,
    required this.rollsWithWaste,
    required this.requiredArea,
  });
}
