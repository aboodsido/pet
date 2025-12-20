import 'package:equatable/equatable.dart';

import '../data/models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final List<TransactionModel> filteredTransactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;
  final String? filterCategory;
  final String? filterType;

  const TransactionLoaded({
    required this.transactions,
    required this.filteredTransactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBalance,
    this.filterCategory,
    this.filterType,
  });

  @override
  List<Object?> get props => [
    transactions,
    filteredTransactions,
    totalIncome,
    totalExpenses,
    totalBalance,
    filterCategory,
    filterType,
  ];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
