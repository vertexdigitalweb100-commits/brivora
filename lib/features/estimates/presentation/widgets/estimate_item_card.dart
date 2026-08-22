import 'package:flutter/material.dart';

import '../../domain/models/estimate_item.dart';

class EstimateItemCard extends StatelessWidget {
  final EstimateItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EstimateItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip('Количество', '${item.quantity} ${item.unit}'),
                _buildInfoChip(
                  'Цена',
                  EstimateItem.formatMoney(item.unitPrice),
                ),
                _buildInfoChip(
                  'Итого',
                  EstimateItem.formatMoney(item.totalPrice),
                ),
              ],
            ),
            if (item.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(item.comment, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }
}
