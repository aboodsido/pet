import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/transactions/data/models/transaction_model.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  int _rangeDays = 30; // 7, 30, 90

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          PopupMenuButton<int>(
            initialValue: _rangeDays,
            onSelected: (val) => setState(() => _rangeDays = val),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 7, child: Text('Last 7 Days')),
                  const PopupMenuItem(value: 30, child: Text('Last 30 Days')),
                  const PopupMenuItem(value: 90, child: Text('Last 90 Days')),
                ],
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final filteredTransactions = _filterByRange(
              state.transactions,
              _rangeDays,
            );

            if (filteredTransactions.isEmpty) {
              return const Center(child: Text('No data for this period'));
            }

            final expenseMap = _groupExpensesByCategory(filteredTransactions);
            final incomeVsExpense = _calculateIncomeVsExpense(
              filteredTransactions,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPeriodComparison(incomeVsExpense),
                const SizedBox(height: 32),
                Text(
                  'Income vs Expense History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildLineChart(filteredTransactions),
                const SizedBox(height: 32),
                Text(
                  'Expense Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(expenseMap),
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Top Categories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...expenseMap.entries.map(
                  (e) => _buildCategoryStat(
                    context,
                    e.key,
                    e.value,
                    incomeVsExpense['expense'] ?? 0,
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  List<TransactionModel> _filterByRange(
    List<TransactionModel> transactions,
    int days,
  ) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    return transactions.where((t) => t.date.isAfter(cutoff)).toList();
  }

  Map<String, double> _calculateIncomeVsExpense(
    List<TransactionModel> transactions,
  ) {
    double income = 0;
    double expense = 0;
    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return {'income': income, 'expense': expense};
  }

  Widget _buildPeriodComparison(Map<String, double> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildComparisonItem(
            'Income',
            stats['income'] ?? 0,
            AppTheme.accentColor,
          ),
          _buildComparisonItem(
            'Expense',
            stats['expense'] ?? 0,
            AppTheme.errorColor,
          ),
          _buildComparisonItem(
            'Net',
            (stats['income'] ?? 0) - (stats['expense'] ?? 0),
            AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String label, double val, Color color) {
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
          style: const TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(List<TransactionModel> transactions) {
    // Group by day for the line chart
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

  Map<String, double> _groupExpensesByCategory(
    List<TransactionModel> transactions,
  ) {
    final Map<String, double> map = {};
    for (var t in transactions) {
      if (t.type == 'expense') {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
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

  Widget _buildCategoryStat(
    BuildContext context,
    String category,
    double amount,
    double total,
  ) {
    if (total == 0) total = 1;
    final percentage = (amount / total) * 100;
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
            value: amount / total,
            backgroundColor: AppTheme.cardColor,
            color: AppTheme.primaryColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
