import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SafetyCard extends StatelessWidget {
  final String score;

  const SafetyCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    switch (score) {
      case 'Critical':
        color = AppTheme.errorColor;
        icon = Icons.warning_amber_rounded;
        text = 'health_critical'.tr();
        break;
      case 'Warning':
        color = Colors.orange;
        icon = Icons.info_outline;
        text = 'health_warning'.tr();
        break;
      default:
        color = AppTheme.accentColor;
        icon = Icons.check_circle_outline;
        text = 'health_stable'.tr();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'financial_health'.tr(),
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
