import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/transactions/data/models/transaction_model.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('app_name'.tr())),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final currencyFormat = NumberFormat.currency(symbol: '\$');
            final monthlyStats = _calculateMonthlyStats(state.transactions);
            final recentTransactions = state.transactions.take(5).toList();

            return RefreshIndicator(
              onRefresh:
                  () async =>
                      context.read<TransactionCubit>().loadTransactions(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(
                    context,
                    title: 'total_balance'.tr(),
                    amount: currencyFormat.format(state.totalBalance),
                    color: AppTheme.primaryColor,
                    isMain: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'total_income'.tr(),
                          amount: currencyFormat.format(state.totalIncome),
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          title: 'total_expenses'.tr(),
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
                        'recent_transactions'.tr(),
                        style: theme.textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to transactions tab - this is handled by MainNavigationScreen usually
                        },
                        child: Text('see_all'.tr()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (recentTransactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'no_transactions'.tr(),
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ),
                    )
                  else
                    ...recentTransactions.map(
                      (t) => _buildTransactionItem(context, t),
                    ),
                ],
              ),
            );
          }

          return Center(child: Text('add_first_transaction'.tr()));
        },
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, Map<String, double> stats) {
    final curFormat = NumberFormat.currency(symbol: '\$');
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'this_month'.tr(),
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                context,
                'income'.tr(),
                curFormat.format(stats['income'] ?? 0),
                AppTheme.accentColor,
              ),
              _buildStat(
                context,
                'expenses'.tr(),
                curFormat.format(stats['expense'] ?? 0),
                AppTheme.errorColor,
              ),
              _buildStat(
                context,
                'savings'.tr(),
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

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
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
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChart(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
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

  Map<String, double> _calculateMonthlyStats(
    List<TransactionModel> transactions,
  ) {
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

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String amount,
    required Color color,
    bool isMain = false,
  }) {
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

  Widget _buildTransactionItem(BuildContext context, TransactionModel t) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = t.type == 'expense';

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
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
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  DateFormat('MMM dd, yyyy').format(t.date),
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
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
