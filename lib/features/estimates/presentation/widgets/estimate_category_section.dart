import 'package:flutter/material.dart';

import '../../domain/models/estimate_item.dart';
import 'estimate_item_card.dart';

class EstimateCategorySection extends StatelessWidget {
  final String title;
  final double total;
  final List<EstimateItem> items;
  final void Function(EstimateItem item) onEdit;
  final void Function(EstimateItem item) onDelete;

  const EstimateCategorySection({
    super.key,
    required this.title,
    required this.total,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(EstimateItem.formatMoney(total), style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Нет позиций в этой категории',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              Column(
                children: items
                    .map(
                      (item) => Column(
                        children: [
                          EstimateItemCard(
                            item: item,
                            onEdit: () => onEdit(item),
                            onDelete: () => onDelete(item),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
