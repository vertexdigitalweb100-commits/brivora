import '../models/concrete_calculation.dart';

class ConcreteCalculatorService {
  ConcreteCalculation calculate({
    required double length,
    required double width,
    required double thicknessCm,
    required String constructionType,
    double wastePercent = 10,
  }) {
    if (length <= 0) {
      throw ArgumentError.value(length, 'length', 'Длина должна быть больше 0');
    }
    if (width <= 0) {
      throw ArgumentError.value(width, 'width', 'Ширина должна быть больше 0');
    }
    if (thicknessCm <= 0) {
      throw ArgumentError.value(thicknessCm, 'thicknessCm', 'Толщина должна быть больше 0');
    }
    if (wastePercent < 0) {
      throw ArgumentError.value(wastePercent, 'wastePercent', 'Запас не может быть отрицательным');
    }

    final thicknessMeters = thicknessCm / 100;
    final surfaceArea = length * width;
    final volumeWithoutWaste = surfaceArea * thicknessMeters;
    final volumeWithWaste = volumeWithoutWaste * (1 + wastePercent / 100);
    final volumeLiters = volumeWithWaste * 1000;

    return ConcreteCalculation(
      length: length,
      width: width,
      thicknessCm: thicknessCm,
      constructionType: constructionType,
      wastePercent: wastePercent,
      surfaceArea: surfaceArea,
      volumeWithoutWaste: volumeWithoutWaste,
      volumeWithWaste: volumeWithWaste,
      volumeLiters: volumeLiters,
    );
  }
}
