import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../transactions/data/models/transaction_model.dart';
import 'category_stat_item.dart';
import 'expense_breakdown_pie.dart';
import 'income_vs_expense_chart.dart';
import 'period_comparison.dart';

class StatisticsBody extends StatelessWidget {
  final List<TransactionModel> transactions;
  final int rangeDays;

  const StatisticsBody({
    super.key,
    required this.transactions,
    required this.rangeDays,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = _filterByRange(transactions, rangeDays);
    if (filtered.isEmpty) return Center(child: Text('no_data'.tr()));

    final expenseMap = _groupExpensesByCategory(filtered);
    final incomeVsExpense = _calculateIncomeVsExpense(filtered);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PeriodComparison(stats: incomeVsExpense),
        const SizedBox(height: 32),
        _SectionTitle(title: 'income_vs_expense'.tr()),
        IncomeVsExpenseChart(transactions: filtered),
        const SizedBox(height: 32),
        _SectionTitle(title: 'expense_breakdown'.tr()),
        const SizedBox(height: 24),
        ExpenseBreakdownPie(expenseMap: expenseMap),
        const SizedBox(height: 32),
        _SectionTitle(title: 'top_categories'.tr()),
        const SizedBox(height: 16),
        ...expenseMap.entries.map(
          (e) => CategoryStatItem(
            category: e.key,
            amount: e.value,
            total: incomeVsExpense['expense'] ?? 0,
          ),
        ),
      ],
    );
  }

  List<TransactionModel> _filterByRange(List<TransactionModel> txs, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return txs.where((t) => t.date.isAfter(cutoff)).toList();
  }

  Map<String, double> _calculateIncomeVsExpense(List<TransactionModel> txs) {
    double income = 0, expense = 0;
    for (var t in txs) {
      t.type == 'income' ? income += t.amount : expense += t.amount;
    }
    return {'income': income, 'expense': expense};
  }

  Map<String, double> _groupExpensesByCategory(List<TransactionModel> txs) {
    final Map<String, double> map = {};
    for (var t in txs.where((t) => t.type == 'expense')) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}
