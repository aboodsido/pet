import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../logic/transaction_cubit.dart';
import 'transaction_amount.dart';
import 'transaction_details.dart';
import 'transaction_icon.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBg(),
      onDismissed: (_) {
        context.read<TransactionCubit>().deleteTransaction(transaction.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('deleted_msg'.tr())));
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              TransactionIcon(
                isExpense: transaction.type == 'expense',
                errorColor: AppTheme.errorColor,
                accentColor: AppTheme.accentColor,
              ),
              const SizedBox(width: 16),
              TransactionDetails(transaction: transaction),
              const SizedBox(width: 8),
              TransactionAmount(
                transaction: transaction,
                errorColor: AppTheme.errorColor,
                accentColor: AppTheme.accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: AppTheme.errorColor,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
