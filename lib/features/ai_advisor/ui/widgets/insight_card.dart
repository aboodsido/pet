import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class InsightCard extends StatelessWidget {
  final String rawText;

  const InsightCard({super.key, required this.rawText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse rawText for potential localized keys and arguments
    // Format: key|arg1|arg2...
    final parts = rawText.split('|');
    final key = parts[0];
    final args = parts.skip(1).toList();

    final translatedText = key.tr(args: args);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              translatedText.replaceAll('**', ''), // Simple markdown clean
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
