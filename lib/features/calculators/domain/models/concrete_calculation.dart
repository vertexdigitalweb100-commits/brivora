class ConcreteCalculation {
  final double length;
  final double width;
  final double thicknessCm;
  final String constructionType;
  final double wastePercent;
  final double surfaceArea;
  final double volumeWithoutWaste;
  final double volumeWithWaste;
  final double volumeLiters;

  ConcreteCalculation({
    required this.length,
    required this.width,
    required this.thicknessCm,
    required this.constructionType,
    required this.wastePercent,
    required this.surfaceArea,
    required this.volumeWithoutWaste,
    required this.volumeWithWaste,
    required this.volumeLiters,
  });
}
