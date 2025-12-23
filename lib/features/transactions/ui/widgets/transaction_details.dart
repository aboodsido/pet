import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';

class TransactionDetails extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (transaction.note?.isNotEmpty ?? false)
            Text(
              transaction.note!,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            DateFormat('MMM dd, yyyy').format(transaction.date),
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
