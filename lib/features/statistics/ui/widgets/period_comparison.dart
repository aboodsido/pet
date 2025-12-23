import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class PeriodComparison extends StatelessWidget {
  final Map<String, double> stats;

  const PeriodComparison({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ComparisonItem(
            label: 'income'.tr(),
            val: stats['income'] ?? 0,
            color: AppTheme.accentColor,
          ),
          _ComparisonItem(
            label: 'expenses'.tr(),
            val: stats['expense'] ?? 0,
            color: AppTheme.errorColor,
          ),
          _ComparisonItem(
            label: 'savings'.tr(),
            val: (stats['income'] ?? 0) - (stats['expense'] ?? 0),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  final String label;
  final double val;
  final Color color;

  const _ComparisonItem({
    required this.label,
    required this.val,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '\$${val.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
