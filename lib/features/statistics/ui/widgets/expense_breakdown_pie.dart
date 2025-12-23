import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ExpenseBreakdownPie extends StatelessWidget {
  final Map<String, double> expenseMap;

  const ExpenseBreakdownPie({super.key, required this.expenseMap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _buildPieSections(expenseMap),
          sectionsSpace: 4,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    final List<Color> colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];

    int i = 0;
    return data.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        value: e.value,
        title: '',
        color: color,
        radius: 30,
      );
    }).toList();
  }
}
