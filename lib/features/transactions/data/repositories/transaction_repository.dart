import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final Box<TransactionModel> _box = Hive.box<TransactionModel>(
    AppConstants.transactionBox,
  );

  List<TransactionModel> getAllTransactions() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  double getTotalBalance() {
    return getTotalIncome() - getTotalExpenses();
  }

  double getTotalIncome() {
    return _box.values
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses() {
    return _box.values
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
