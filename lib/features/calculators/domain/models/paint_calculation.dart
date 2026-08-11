class PaintCalculation {
  final double roomLength;
  final double roomWidth;
  final double ceilingHeight;
  final int doorCount;
  final double doorWidth;
  final double doorHeight;
  final int windowCount;
  final double windowWidth;
  final double windowHeight;
  final int coats;
  final double coverage;
  final double wastePercent;
  final String paintScope;
  final double wallArea;
  final double ceilingArea;
  final double doorArea;
  final double windowArea;
  final double usableWallArea;
  final double totalArea;
  final double paintArea;
  final double requiredArea;
  final double paintLiters;
  final double paintLitersRounded;

  PaintCalculation({
    required this.roomLength,
    required this.roomWidth,
    required this.ceilingHeight,
    required this.doorCount,
    required this.doorWidth,
    required this.doorHeight,
    required this.windowCount,
    required this.windowWidth,
    required this.windowHeight,
    required this.coats,
    required this.coverage,
    required this.wastePercent,
    required this.paintScope,
    required this.wallArea,
    required this.ceilingArea,
    required this.doorArea,
    required this.windowArea,
    required this.usableWallArea,
    required this.totalArea,
    required this.paintArea,
    required this.requiredArea,
    required this.paintLiters,
    required this.paintLitersRounded,
  });
}
