import 'package:flutter/material.dart';

import '../../domain/models/estimate_item.dart';

class AddEstimateItemDialog extends StatefulWidget {
  final String projectId;
  final EstimateItem? existingItem;

  const AddEstimateItemDialog({
    super.key,
    required this.projectId,
    this.existingItem,
  });

  @override
  State<AddEstimateItemDialog> createState() => _AddEstimateItemDialogState();
}

class _AddEstimateItemDialogState extends State<AddEstimateItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _commentController;
  String _category = 'material';
  String _unit = 'шт.';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingItem?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.existingItem?.quantity.toString() ?? '1',
    );
    _unitPriceController = TextEditingController(
      text: widget.existingItem?.unitPrice.toString() ?? '0',
    );
    _commentController = TextEditingController(text: widget.existingItem?.comment ?? '');
    _category = widget.existingItem?.category ?? 'material';
    _unit = widget.existingItem?.unit ?? 'шт.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  double get _quantity {
    return double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
  }

  double get _unitPrice {
    return double.tryParse(_unitPriceController.text.replaceAll(',', '.')) ?? 0.0;
  }

  double get _totalPrice => _quantity * _unitPrice;

  bool get _canSave {
    return _nameController.text.trim().isNotEmpty && _quantity > 0 && _unitPrice >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingItem == null ? 'Новая позиция' : 'Редактировать позицию'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: EstimateItem.categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(EstimateItem.categoryTitle(category)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Количество'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    items: EstimateItem.units
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _unit = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Единица'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _unitPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Цена за единицу'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Комментарий'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Итог: ${EstimateItem.formatMoney(_totalPrice)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _canSave ? _save : null,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  void _save() {
    final item = EstimateItem(
      id: widget.existingItem?.id ?? '',
      projectId: widget.projectId,
      name: _nameController.text.trim(),
      category: _category,
      quantity: _quantity,
      unit: _unit,
      unitPrice: _unitPrice,
      totalPrice: _totalPrice,
      comment: _commentController.text.trim(),
      createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(item);
  }
}
