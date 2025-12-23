import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TransactionSaveButton extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const TransactionSaveButton({
    super.key,
    required this.isEdit,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isEdit ? 'update'.tr() : 'save'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
