import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TransactionFormFields extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController categoryController;
  final TextEditingController noteController;

  const TransactionFormFields({
    super.key,
    required this.amountController,
    required this.categoryController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'amount'.tr(),
            prefixText: '\$ ',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: categoryController,
          decoration: InputDecoration(
            labelText: 'category'.tr(),
            hintText: 'category_hint'.tr(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: 'note'.tr(),
            hintText: 'note_hint'.tr(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
