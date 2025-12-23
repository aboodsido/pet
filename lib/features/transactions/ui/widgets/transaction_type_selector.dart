import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;
  final String expenseLabel;
  final String incomeLabel;
  final Color errorColor;
  final Color accentColor;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.expenseLabel,
    required this.incomeLabel,
    required this.errorColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TypeButton(
          type: 'expense',
          label: expenseLabel,
          color: errorColor,
          isSelected: selectedType == 'expense',
          onTap: () => onTypeSelected('expense'),
        ),
        const SizedBox(width: 12),
        _TypeButton(
          type: 'income',
          label: incomeLabel,
          color: accentColor,
          isSelected: selectedType == 'income',
          onTap: () => onTypeSelected('income'),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String type;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.type,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
