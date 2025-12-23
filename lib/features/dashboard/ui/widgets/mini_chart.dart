import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transactions/data/models/transaction_model.dart';

class MiniChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const MiniChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_overview'.tr(),
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpots(transactions),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return [const FlSpot(0, 0)];
    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));
    final List<FlSpot> spots = [];
    double balance = 0;
    for (int i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      balance += (t.type == 'income' ? t.amount : -t.amount);
      spots.add(FlSpot(i.toDouble(), balance));
    }
    return spots;
  }
}
