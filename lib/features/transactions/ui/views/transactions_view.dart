import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/transactions/data/models/transaction_model.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('transactions'.tr())),
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
                    return Center(child: Text('no_transactions'.tr()));
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
                'type'.tr(),
                state.filterType != null ? state.filterType!.tr() : 'all'.tr(),
                ['all', 'expense', 'income'],
                (val) {
                  context.read<TransactionCubit>().setFilter(type: val);
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'category'.tr(),
                state.filterCategory ?? 'all'.tr(),
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
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder:
          (context) =>
              options
                  .map(
                    (opt) => PopupMenuItem(value: opt, child: Text(opt.tr())),
                  )
                  .toList(),
      child: Chip(
        label: Text('$label: ${selected.tr()}'),
        backgroundColor: theme.cardColor,
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel t) {
    final curFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = t.type == 'expense';
    final theme = Theme.of(context);

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
        ).showSnackBar(SnackBar(content: Text('deleted_msg'.tr())));
      },
      child: InkWell(
        onTap: () => _showAddEditDialog(context, transaction: t),
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
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(t.date),
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
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

    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                isEdit ? 'edit_transaction'.tr() : 'add_transaction'.tr(),
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
              _buildTypeButton('expense', 'expense'.tr(), AppTheme.errorColor),
              const SizedBox(width: 12),
              _buildTypeButton('income', 'income'.tr(), AppTheme.accentColor),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'amount'.tr(),
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'category'.tr(),
              hintText: 'category_hint'.tr(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'note'.tr(),
              hintText: 'note_hint'.tr(),
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
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: theme.textTheme.bodyMedium?.color,
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
                isEdit ? 'update'.tr() : 'save'.tr(),
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
