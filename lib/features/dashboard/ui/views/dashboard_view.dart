import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Expense Dashboard')),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final currencyFormat = NumberFormat.currency(symbol: '\$');
            final monthlyStats = _calculateMonthlyStats(state.transactions);

            return RefreshIndicator(
              onRefresh:
                  () async =>
                      context.read<TransactionCubit>().loadTransactions(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(
                    title: 'Total Balance',
                    amount: currencyFormat.format(state.totalBalance),
                    color: AppTheme.primaryColor,
                    isMain: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total Income',
                          amount: currencyFormat.format(state.totalIncome),
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total Expenses',
                          amount: currencyFormat.format(state.totalExpenses),
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMonthlySummary(context, monthlyStats),
                  const SizedBox(height: 24),
                  _buildMiniChart(context, state.transactions),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('No transactions yet'),
                      ),
                    )
                  else
                    ...state.transactions
                        .take(5)
                        .map((t) => _buildTransactionItem(context, t)),
                ],
              ),
            );
          }

          return const Center(child: Text('Add your first transaction!'));
        },
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, Map<String, double> stats) {
    final curFormat = NumberFormat.currency(symbol: '\$');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Month',
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                'Income',
                curFormat.format(stats['income'] ?? 0),
                AppTheme.accentColor,
              ),
              _buildStat(
                'Expenses',
                curFormat.format(stats['expense'] ?? 0),
                AppTheme.errorColor,
              ),
              _buildStat(
                'Savings',
                curFormat.format(
                  (stats['income'] ?? 0) - (stats['expense'] ?? 0),
                ),
                AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
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

  Widget _buildMiniChart(BuildContext context, dynamic transactions) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Overview',
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
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

  List<FlSpot> _getSpots(dynamic transactions) {
    if (transactions.isEmpty) return [const FlSpot(0, 0)];
    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    final List<FlSpot> spots = [];
    double balance = 0;
    for (int i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      balance += (t.type == 'income' ? t.amount : -t.amount);
      spots.add(FlSpot(i.toDouble(), balance));
    }
    return spots;
  }

  Map<String, double> _calculateMonthlyStats(dynamic transactions) {
    final now = DateTime.now();
    double income = 0;
    double expense = 0;
    for (var t in transactions) {
      if (t.date.year == now.year && t.date.month == now.month) {
        if (t.type == 'income') {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
    }
    return {'income': income, 'expense': expense};
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color color,
    bool isMain = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMain ? 24 : 16),
      decoration: BoxDecoration(
        color: isMain ? color : AppTheme.cardColor,
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
                : Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                      : AppTheme.secondaryTextColor,
              fontSize: isMain ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: isMain ? Colors.white : AppTheme.textColor,
              fontSize: isMain ? 32 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, dynamic t) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = t.type == 'expense';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? AppTheme.errorColor : AppTheme.accentColor)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: isExpense ? AppTheme.errorColor : AppTheme.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (t.note != null && t.note!.isNotEmpty)
                  Text(
                    t.note!,
                    style: const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  DateFormat('MMM dd, yyyy').format(t.date),
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isExpense ? '-' : '+'}${currencyFormat.format(t.amount)}',
            style: TextStyle(
              color: isExpense ? AppTheme.errorColor : AppTheme.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
