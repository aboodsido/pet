import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/logic/transaction_state.dart';
import 'dashboard_empty_state.dart';
import 'dashboard_recent_header.dart';
import 'mini_chart.dart';
import 'monthly_summary.dart';
import 'summary_card.dart';
import 'transaction_item.dart'
    as dashboard; // Local version if any, but it's okay

class DashboardBody extends StatelessWidget {
  final TransactionLoaded state;
  const DashboardBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final curFormat = NumberFormat.currency(symbol: '\$');
    final monthlyStats = _calculateMonthlyStats(state.transactions);
    final recent = state.transactions.take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SummaryCard(
          title: 'total_balance'.tr(),
          amount: curFormat.format(state.totalBalance),
          color: AppTheme.primaryColor,
          isMain: true,
        ),
        const SizedBox(height: 16),
        _buildIncomeExpenseRow(curFormat),
        const SizedBox(height: 24),
        MonthlySummary(stats: monthlyStats),
        const SizedBox(height: 24),
        MiniChart(transactions: state.transactions),
        const SizedBox(height: 32),
        DashboardRecentHeader(onSeeAll: () {}),
        const SizedBox(height: 16),
        if (recent.isEmpty)
          const DashboardEmptyState()
        else
          ...recent.map((t) => dashboard.TransactionItem(transaction: t)),
      ],
    );
  }

  Widget _buildIncomeExpenseRow(NumberFormat curFormat) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: 'total_income'.tr(),
            amount: curFormat.format(state.totalIncome),
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryCard(
            title: 'total_expenses'.tr(),
            amount: curFormat.format(state.totalExpenses),
            color: AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Map<String, double> _calculateMonthlyStats(List<TransactionModel> txs) {
    final now = DateTime.now();
    double income = 0, expense = 0;
    for (var t in txs) {
      if (t.date.year == now.year && t.date.month == now.month) {
        t.type == 'income' ? income += t.amount : expense += t.amount;
      }
    }
    return {'income': income, 'expense': expense};
  }
}
