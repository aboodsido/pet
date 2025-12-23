import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transactions/data/models/transaction_model.dart';

class IncomeVsExpenseChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const IncomeVsExpenseChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, double> incomeMap = {};
    final Map<DateTime, double> expenseMap = {};

    for (var t in transactions) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      if (t.type == 'income') {
        incomeMap[date] = (incomeMap[date] ?? 0) + t.amount;
      } else {
        expenseMap[date] = (expenseMap[date] ?? 0) + t.amount;
      }
    }

    final sortedDates =
        <dynamic>{...incomeMap.keys, ...expenseMap.keys}.toList()..sort();
    if (sortedDates.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots:
                  sortedDates
                      .map(
                        (d) => FlSpot(
                          d.millisecondsSinceEpoch.toDouble(),
                          incomeMap[d] ?? 0,
                        ),
                      )
                      .toList(),
              isCurved: true,
              color: AppTheme.accentColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots:
                  sortedDates
                      .map(
                        (d) => FlSpot(
                          d.millisecondsSinceEpoch.toDouble(),
                          expenseMap[d] ?? 0,
                        ),
                      )
                      .toList(),
              isCurved: true,
              color: AppTheme.errorColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
