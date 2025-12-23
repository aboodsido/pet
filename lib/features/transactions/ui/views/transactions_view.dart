import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/features/transactions/data/models/transaction_model.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

import '../widgets/add_edit_transaction_dialog.dart';
import '../widgets/filter_bar.dart';
import '../widgets/transaction_item.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('transactions'.tr())),
      body: Column(
        children: [
          const FilterBar(),
          Expanded(
            child: BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransactionLoaded) {
                  if (state.filteredTransactions.isEmpty) {
                    return Center(child: Text('no_transactions'.tr()));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final t = state.filteredTransactions[index];
                      return TransactionItem(
                        transaction: t,
                        onTap:
                            () => _showAddEditDialog(context, transaction: t),
                      );
                    },
                  );
                }

                return Center(child: Text('something_went_wrong'.tr()));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context, {
    TransactionModel? transaction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => BlocProvider.value(
            value: context.read<TransactionCubit>(),
            child: AddEditTransactionDialog(transaction: transaction),
          ),
    );
  }
}
