import 'package:flutter_bloc/flutter_bloc.dart';

import '../../transactions/data/repositories/transaction_repository.dart';
import 'ai_advisor_state.dart';

class AiAdvisorCubit extends Cubit<AiAdvisorState> {
  final TransactionRepository _repository;

  AiAdvisorCubit(this._repository) : super(AiAdvisorInitial());

  void analyzeSpending() {
    emit(AiAdvisorLoading());
    try {
      final transactions = _repository.getAllTransactions();
      if (transactions.isEmpty) {
        emit(
          const AiAdvisorLoaded(
            insights: ['add_transactions_insight'],
            safetyScore: 'Neutral',
          ),
        );
        return;
      }

      final insights = <String>[];
      final totalIncome = _repository.getTotalIncome();
      final totalExpenses = _repository.getTotalExpenses();

      // Basic heuristic analysis
      if (totalIncome > 0) {
        final expenseRatio = totalExpenses / totalIncome;
        if (expenseRatio > 0.8) {
          insights.add('spent_over_80_insight');
        } else if (expenseRatio < 0.5) {
          insights.add('saving_over_50_insight');
        } else {
          insights.add('spending_healthy_insight');
        }
      }

      // Category analysis
      final expenseMap = <String, double>{};
      for (var t in transactions) {
        if (t.type == 'expense') {
          expenseMap[t.category] = (expenseMap[t.category] ?? 0) + t.amount;
        }
      }

      if (expenseMap.isNotEmpty) {
        final sortedCategories =
            expenseMap.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        final topCategory = sortedCategories.first;
        final topPercent = (topCategory.value / totalExpenses) * 100;

        insights.add(
          'highest_category_insight|${topCategory.key}|${topPercent.toStringAsFixed(1)}',
        );

        if (topCategory.key.toLowerCase().contains('food') && topPercent > 30) {
          insights.add('food_spending_tip');
        }
      }

      // Savings tip
      insights.add('rule_50_30_20_tip');

      String safetyScore = 'Good';
      if (totalIncome > 0 && totalExpenses > totalIncome) {
        safetyScore = 'Critical';
        insights.add('danger_expenses_exceed');
      } else if (totalIncome > 0 && (totalExpenses / totalIncome) > 0.7) {
        safetyScore = 'Warning';
      }

      emit(AiAdvisorLoaded(insights: insights, safetyScore: safetyScore));
    } catch (e) {
      emit(AiAdvisorError(e.toString()));
    }
  }
}
