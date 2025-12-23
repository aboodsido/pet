import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CategoryStatItem extends StatelessWidget {
  final String category;
  final double amount;
  final double total;

  const CategoryStatItem({
    super.key,
    required this.category,
    required this.amount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    var effectiveTotal = total == 0 ? 1.0 : total;
    final percentage = (amount / effectiveTotal) * 100;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: amount / effectiveTotal,
            backgroundColor: theme.cardColor,
            color: AppTheme.primaryColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
