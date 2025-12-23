import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/transaction_model.dart';
import '../../logic/transaction_cubit.dart';
import 'transaction_dialog_body.dart';

class AddEditTransactionDialog extends StatefulWidget {
  final TransactionModel? transaction;
  const AddEditTransactionDialog({super.key, this.transaction});
  @override
  State<AddEditTransactionDialog> createState() =>
      _AddEditTransactionDialogState();
}

class _AddEditTransactionDialogState extends State<AddEditTransactionDialog> {
  late final TextEditingController _amountController,
      _categoryController,
      _noteController;
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: TransactionDialogBody(
        isEdit: widget.transaction != null,
        selectedType: _selectedType,
        selectedDate: _selectedDate,
        amountController: _amountController,
        categoryController: _categoryController,
        noteController: _noteController,
        onTypeSelected: (t) => setState(() => _selectedType = t),
        onDateSelected: (d) => setState(() => _selectedDate = d),
        onSave: _onSave,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _onSave() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || _categoryController.text.isEmpty) return;
    final tx = TransactionModel(
      id: widget.transaction?.id,
      amount: amount,
      type: _selectedType,
      category: _categoryController.text,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    if (widget.transaction != null) {
      context.read<TransactionCubit>().updateTransaction(tx);
    } else {
      context.read<TransactionCubit>().addTransaction(tx);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
