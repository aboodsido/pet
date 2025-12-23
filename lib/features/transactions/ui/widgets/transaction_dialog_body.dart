import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'transaction_date_picker.dart';
import 'transaction_dialog_header.dart';
import 'transaction_form_fields.dart';
import 'transaction_save_button.dart';
import 'transaction_type_selector.dart';

class TransactionDialogBody extends StatelessWidget {
  final bool isEdit;
  final String selectedType;
  final DateTime selectedDate;
  final TextEditingController amountController,
      categoryController,
      noteController;
  final Function(String) onTypeSelected;
  final Function(DateTime) onDateSelected;
  final VoidCallback onSave, onClose;

  const TransactionDialogBody({
    super.key,
    required this.isEdit,
    required this.selectedType,
    required this.selectedDate,
    required this.amountController,
    required this.categoryController,
    required this.noteController,
    required this.onTypeSelected,
    required this.onDateSelected,
    required this.onSave,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        TransactionDialogHeader(
          title: isEdit ? 'edit_transaction'.tr() : 'add_transaction'.tr(),
          onClose: onClose,
        ),
        const SizedBox(height: 24),
        TransactionTypeSelector(
          selectedType: selectedType,
          onTypeSelected: onTypeSelected,
          expenseLabel: 'expense'.tr(),
          incomeLabel: 'income'.tr(),
          errorColor: AppTheme.errorColor,
          accentColor: AppTheme.accentColor,
        ),
        const SizedBox(height: 24),
        TransactionFormFields(
          amountController: amountController,
          categoryController: categoryController,
          noteController: noteController,
        ),
        const SizedBox(height: 16),
        TransactionDatePicker(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: 32),
        TransactionSaveButton(
          isEdit: isEdit,
          onPressed: onSave,
          backgroundColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}
