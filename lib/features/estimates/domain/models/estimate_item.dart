import 'package:cloud_firestore/cloud_firestore.dart';

class EstimateItem {
  final String id;
  final String projectId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EstimateItem({
    required this.id,
    required this.projectId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  EstimateItem copyWith({
    String? id,
    String? projectId,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final updatedQuantity = quantity ?? this.quantity;
    final updatedUnitPrice = unitPrice ?? this.unitPrice;
    return EstimateItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: updatedQuantity,
      unit: unit ?? this.unit,
      unitPrice: updatedUnitPrice,
      totalPrice: totalPrice ?? (updatedQuantity * updatedUnitPrice),
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory EstimateItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final quantity = (data['quantity'] ?? 0).toDouble();
    final unitPrice = (data['unitPrice'] ?? 0).toDouble();
    return EstimateItem(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'other',
      quantity: quantity,
      unit: data['unit'] as String? ?? 'шт.',
      unitPrice: unitPrice,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? quantity * unitPrice,
      comment: data['comment'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static const List<String> categories = [
    'material',
    'labor',
    'delivery',
    'tools',
    'other',
  ];

  static const Map<String, String> categoryTitles = {
    'material': 'Материалы',
    'labor': 'Работа',
    'delivery': 'Доставка',
    'tools': 'Инструменты',
    'other': 'Прочее',
  };

  static const List<String> units = [
    'шт.',
    'м',
    'м²',
    'м³',
    'кг',
    'л',
    'мешок',
    'уп.',
    'час',
    'день',
  ];

  static String categoryTitle(String category) {
    return categoryTitles[category] ?? 'Прочее';
  }

  static EstimateItem calculatorItem({
    required String projectId,
    required String name,
    double quantity = 0,
    String unit = 'шт.',
    String category = 'material',
    String comment = '',
  }) {
    return EstimateItem(
      id: '',
      projectId: projectId,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      unitPrice: 0,
      totalPrice: 0,
      comment: comment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static String formatMoney(double value) {
    final int rounded = value.round();
    final text = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} ₸';
  }
}
