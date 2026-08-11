class LaminateCalculation {
  final double roomLength;
  final double roomWidth;
  final double panelLength;
  final double panelWidth;
  final int panelsPerPack;
  final double wastePercent;
  final double roomArea;
  final double panelArea;
  final int panelsWithoutWaste;
  final int panelsWithWaste;
  final int packs;

  LaminateCalculation({
    required this.roomLength,
    required this.roomWidth,
    required this.panelLength,
    required this.panelWidth,
    required this.panelsPerPack,
    required this.wastePercent,
    required this.roomArea,
    required this.panelArea,
    required this.panelsWithoutWaste,
    required this.panelsWithWaste,
    required this.packs,
  });
}
