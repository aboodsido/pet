import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MonthlySummary extends StatelessWidget {
  final Map<String, double> stats;

  const MonthlySummary({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final curFormat = NumberFormat.currency(symbol: '\$');
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'this_month'.tr(),
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatWidget(
                label: 'income'.tr(),
                value: curFormat.format(stats['income'] ?? 0),
                color: AppTheme.accentColor,
              ),
              _StatWidget(
                label: 'expenses'.tr(),
                value: curFormat.format(stats['expense'] ?? 0),
                color: AppTheme.errorColor,
              ),
              _StatWidget(
                label: 'savings'.tr(),
                value: curFormat.format(
                  (stats['income'] ?? 0) - (stats['expense'] ?? 0),
                ),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatWidget({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
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
