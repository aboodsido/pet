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
            insights: [
              'Add some transactions to get AI-powered financial advice!',
            ],
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
          insights.add(
            '⚠️ You have spent over 80% of your income this month. Consider cutting down on non-essential items.',
          );
        } else if (expenseRatio < 0.5) {
          insights.add(
            '✅ Great job! You are saving more than 50% of your income.',
          );
        } else {
          insights.add(
            'ℹ️ Your spending is within a healthy range of your income.',
          );
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
          'Your highest spending category is **${topCategory.key}**, making up ${topPercent.toStringAsFixed(1)}% of your total expenses.',
        );

        if (topCategory.key.toLowerCase().contains('food') && topPercent > 30) {
          insights.add(
            '🍔 Dining and groceries are your biggest costs. Maybe try meal prepping to save more?',
          );
        }
      }

      // Savings tip
      insights.add(
        '💡 Tip: Try the 50/30/20 rule: 50% for needs, 30% for wants, and 20% for savings.',
      );

      String safetyScore = 'Good';
      if (totalIncome > 0 && totalExpenses > totalIncome) {
        safetyScore = 'Critical';
        insights.add(
          '🚨 Danger: Your expenses exceed your income. You are currently losing money!',
        );
      } else if (totalIncome > 0 && (totalExpenses / totalIncome) > 0.7) {
        safetyScore = 'Warning';
      }

      emit(AiAdvisorLoaded(insights: insights, safetyScore: safetyScore));
    } catch (e) {
      emit(AiAdvisorError(e.toString()));
    }
  }
}
