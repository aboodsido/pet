import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final bool isMain;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isMain ? 24 : 16),
      decoration: BoxDecoration(
        color: isMain ? color : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border:
            isMain
                ? null
                : Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color:
                  isMain
                      ? Colors.white.withValues(alpha: 0.8)
                      : theme.textTheme.bodyMedium?.color,
              fontSize: isMain ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: isMain ? Colors.white : theme.textTheme.bodyLarge?.color,
              fontSize: isMain ? 32 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
