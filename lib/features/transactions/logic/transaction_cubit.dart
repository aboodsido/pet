import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repository;

  TransactionCubit(this._repository) : super(TransactionInitial());

  void loadTransactions({String? category, String? type}) {
    emit(TransactionLoading());
    try {
      final allTransactions = _repository.getAllTransactions();

      var filtered = allTransactions;
      if (category != null && category != 'All') {
        filtered = filtered.where((t) => t.category == category).toList();
      }
      if (type != null && type != 'All') {
        filtered = filtered.where((t) => t.type == type.toLowerCase()).toList();
      }

      final income = _repository.getTotalIncome();
      final expenses = _repository.getTotalExpenses();
      final balance = _repository.getTotalBalance();

      emit(
        TransactionLoaded(
          transactions: allTransactions,
          filteredTransactions: filtered,
          totalIncome: income,
          totalExpenses: expenses,
          totalBalance: balance,
          filterCategory: category,
          filterType: type,
        ),
      );
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void setFilter({String? category, String? type}) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      loadTransactions(
        category: category ?? currentState.filterCategory,
        type: type ?? currentState.filterType,
      );
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.addTransaction(transaction);
      final currentState =
          state is TransactionLoaded ? state as TransactionLoaded : null;
      loadTransactions(
        category: currentState?.filterCategory,
        type: currentState?.filterType,
      );
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      final currentState =
          state is TransactionLoaded ? state as TransactionLoaded : null;
      loadTransactions(
        category: currentState?.filterCategory,
        type: currentState?.filterType,
      );
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      final currentState =
          state is TransactionLoaded ? state as TransactionLoaded : null;
      loadTransactions(
        category: currentState?.filterCategory,
        type: currentState?.filterType,
      );
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
