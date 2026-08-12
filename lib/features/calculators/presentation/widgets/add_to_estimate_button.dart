import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../projects/domain/models/project.dart';
import '../../../estimates/domain/models/estimate_item.dart';
import '../../../estimates/presentation/providers/estimate_provider.dart';
import '../../../estimates/presentation/widgets/add_estimate_item_dialog.dart';

class AddToEstimateButton extends StatelessWidget {
  final Project? project;
  final String itemName;
  final double quantity;
  final String unit;
  final String category;
  final String? comment;

  const AddToEstimateButton({
    super.key,
    required this.project,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.category,
    this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: project == null ? null : () => _handleAdd(context),
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text('Добавить в смету'),
    );
  }

  Future<void> _handleAdd(BuildContext context) async {
    final currentProject = project;

    if (currentProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Откройте калькулятор из проекта, '
            'чтобы добавить результат в смету.',
          ),
        ),
      );
      return;
    }

    final estimateItem = EstimateItem.calculatorItem(
      projectId: currentProject.id,
      name: itemName,
      quantity: quantity,
      unit: unit,
      category: category,
      comment: comment ?? '',
    );

    final result = await showDialog<EstimateItem>(
      context: context,
      builder: (_) {
        return AddEstimateItemDialog(
          projectId: currentProject.id,
          existingItem: estimateItem,
        );
      },
    );

    if (result == null) return;

    try {
      await context.read<EstimateProvider>().addEstimateItem(result);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Позиция добавлена в смету')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить в смету: $e')),
      );
    }
  }
}
