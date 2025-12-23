import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/transaction_cubit.dart';
import '../../logic/transaction_state.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'type'.tr(),
                selected:
                    state.filterType != null
                        ? state.filterType!.tr()
                        : 'all'.tr(),
                options: ['all', 'expense', 'income'],
                onSelected: (val) {
                  context.read<TransactionCubit>().setFilter(type: val);
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'category'.tr(),
                selected: state.filterCategory ?? 'all'.tr(),
                options: [
                  'All',
                  ...state.transactions.map((t) => t.category).toSet(),
                ],
                onSelected: (val) {
                  context.read<TransactionCubit>().setFilter(category: val);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String selected;
  final Iterable<String> options;
  final Function(String) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
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
}
