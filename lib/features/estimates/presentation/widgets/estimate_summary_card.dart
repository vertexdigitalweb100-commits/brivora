import 'package:flutter/material.dart';

import '../../domain/models/estimate_item.dart';
import '../providers/estimate_provider.dart';

class EstimateSummaryCard extends StatelessWidget {
  final EstimateProvider provider;

  const EstimateSummaryCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Общая стоимость', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              EstimateItem.formatMoney(provider.grandTotal),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryRow('Материалы', provider.totalMaterials, context),
            const SizedBox(height: 8),
            _buildSummaryRow('Работа', provider.totalLabor, context),
            const SizedBox(height: 8),
            _buildSummaryRow('Доставка', provider.totalDelivery, context),
            const SizedBox(height: 8),
            _buildSummaryRow('Инструменты', provider.totalTools, context),
            const SizedBox(height: 8),
            _buildSummaryRow('Прочее', provider.totalOther, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          EstimateItem.formatMoney(value),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
