import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/transactions/data/models/transaction_model.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransactionLoaded) {
                  if (state.filteredTransactions.isEmpty) {
                    return const Center(child: Text('No transactions found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final t = state.filteredTransactions[index];
                      return _buildTransactionItem(context, t);
                    },
                  );
                }

                return const Center(child: Text('Something went wrong'));
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

  Widget _buildFilterBar(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                context,
                'Type',
                state.filterType ?? 'All',
                ['All', 'Expense', 'Income'],
                (val) {
                  context.read<TransactionCubit>().setFilter(type: val);
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Category',
                state.filterCategory ?? 'All',
                ['All', ...state.transactions.map((t) => t.category).toSet()],
                (val) {
                  context.read<TransactionCubit>().setFilter(category: val);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String selected,
    Iterable<String> options,
    Function(String) onSelected,
  ) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder:
          (context) =>
              options
                  .map((opt) => PopupMenuItem(value: opt, child: Text(opt)))
                  .toList(),
      child: Chip(
        label: Text('$label: $selected'),
        backgroundColor: AppTheme.cardColor,
        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel t) {
    final curFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = t.type == 'expense';

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TransactionCubit>().deleteTransaction(t.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      },
      child: InkWell(
        onTap: () => _showAddEditDialog(context, transaction: t),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isExpense
                          ? AppTheme.errorColor
                          : AppTheme.accentColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isExpense ? AppTheme.errorColor : AppTheme.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (t.note != null && t.note!.isNotEmpty)
                      Text(
                        t.note!,
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(t.date),
                      style: const TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isExpense ? '-' : '+'}${curFormat.format(t.amount)}',
                style: TextStyle(
                  color: isExpense ? AppTheme.errorColor : AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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

class AddEditTransactionDialog extends StatefulWidget {
  final TransactionModel? transaction;
  const AddEditTransactionDialog({super.key, this.transaction});

  @override
  State<AddEditTransactionDialog> createState() =>
      _AddEditTransactionDialogState();
}

class _AddEditTransactionDialogState extends State<AddEditTransactionDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _noteController;
  late String _selectedType;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.transaction?.category ?? '',
    );
    _noteController = TextEditingController(
      text: widget.transaction?.note ?? '',
    );
    _selectedType = widget.transaction?.type ?? 'expense';
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Edit Transaction' : 'Add Transaction',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildTypeButton('expense', 'Expense', AppTheme.errorColor),
              const SizedBox(width: 12),
              _buildTypeButton('income', 'Income', AppTheme.accentColor),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(labelText: 'Amount', prefixText: '\$ '),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Category',
              hintText: 'e.g. Food, Salary, Rent',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'What exactly was this?',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null && mounted) setState(() => _selectedDate = date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppTheme.secondaryTextColor,
                  ),
                  const SizedBox(width: 12),
                  Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final amountText = _amountController.text.replaceAll(',', '.');
                final amount = double.tryParse(amountText);
                if (amount == null || _categoryController.text.isEmpty) return;

                final transaction = TransactionModel(
                  id: widget.transaction?.id,
                  amount: amount,
                  type: _selectedType,
                  category: _categoryController.text,
                  date: _selectedDate,
                  note:
                      _noteController.text.isEmpty
                          ? null
                          : _noteController.text,
                );

                if (isEdit) {
                  context.read<TransactionCubit>().updateTransaction(
                    transaction,
                  );
                } else {
                  context.read<TransactionCubit>().addTransaction(transaction);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isEdit ? 'Update Transaction' : 'Save Transaction',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildTypeButton(String type, String label, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
