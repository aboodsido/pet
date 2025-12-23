import 'package:flutter/material.dart';

class TransactionIcon extends StatelessWidget {
  final bool isExpense;
  final Color errorColor;
  final Color accentColor;

  const TransactionIcon({
    super.key,
    required this.isExpense,
    required this.errorColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? errorColor : accentColor;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
        color: color,
        size: 20,
      ),
    );
  }
}
