import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';

class TransactionAmount extends StatelessWidget {
  final TransactionModel transaction;
  final Color errorColor;
  final Color accentColor;

  const TransactionAmount({
    super.key,
    required this.transaction,
    required this.errorColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final curFormat = NumberFormat.currency(symbol: '\$');
    return Text(
      '${isExpense ? '-' : '+'}${curFormat.format(transaction.amount)}',
      style: TextStyle(
        color: isExpense ? errorColor : accentColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
