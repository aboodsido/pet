import 'package:flutter_bloc/flutter_bloc.dart';

import '../../transactions/data/repositories/transaction_repository.dart';
import '../data/repositories/ai_advisor_repository.dart';
import 'ai_advisor_state.dart';

class AiAdvisorCubit extends Cubit<AiAdvisorState> {
  final TransactionRepository _repository;
  final AiAdvisorRepository _aiRepository;

  AiAdvisorCubit(this._repository, this._aiRepository)
    : super(AiAdvisorInitial());

  Future<void> analyzeSpending() async {
    emit(const AiAdvisorLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));

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

      // Basic heuristic analysis (kept as fallback/instant feedback)
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

  Future<void> askAi(String question) async {
    if (state is! AiAdvisorLoaded) return;
    final currentState = state as AiAdvisorLoaded;

    emit(AiAdvisorLoading(userQuestion: question));

    try {
      final transactions = _repository.getAllTransactions();
      final totalIncome = _repository.getTotalIncome();
      final totalExpenses = _repository.getTotalExpenses();
      final balance = _repository.getTotalBalance();

      // Create a context summary for the AI
      final txSummary = transactions
          .take(20)
          .map(
            (t) =>
                '${t.date.toIso8601String().split('T')[0]}: ${t.type} ${t.amount} in ${t.category}',
          )
          .join('\n');

      final prompt = """
          Act as a professional financial advisor. 
          Current Financial Status:
          - Total Income: \$${totalIncome.toStringAsFixed(2)}
          - Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
          - Current Balance: \$${balance.toStringAsFixed(2)}

          Recent Transactions:
          $txSummary

          User Question: "$question"

          Please provide a concise, helpful, and professional answer based on this data. If the user asks about buying something, analyze their balance and spending habits.
          """;

      final response = await _aiRepository.getAiAdvice(prompt);

      final newHistory =
          List<Map<String, String>>.from(currentState.chatHistory)
            ..add({'role': 'user', 'content': question})
            ..add({'role': 'assistant', 'content': response});

      emit(
        currentState.copyWith(aiResponse: response, chatHistory: newHistory),
      );
    } catch (e) {
      emit(AiAdvisorError(e.toString()));
    }
  }

  void clearChat() {
    if (state is AiAdvisorLoaded) {
      emit(
        (state as AiAdvisorLoaded).copyWith(chatHistory: [], aiResponse: null),
      );
    }
  }
}
