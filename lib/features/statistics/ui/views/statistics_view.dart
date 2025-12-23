import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

import '../widgets/statistics_body.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  int _rangeDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('stats'.tr()), actions: [_buildRangePicker()]),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            return StatisticsBody(
              transactions: state.transactions,
              rangeDays: _rangeDays,
            );
          }
          return Center(child: Text('something_went_wrong'.tr()));
        },
      ),
    );
  }

  Widget _buildRangePicker() {
    return PopupMenuButton<int>(
      initialValue: _rangeDays,
      onSelected: (val) => setState(() => _rangeDays = val),
      itemBuilder:
          (context) => [
            PopupMenuItem(value: 7, child: Text('last_7_days'.tr())),
            PopupMenuItem(value: 30, child: Text('last_30_days'.tr())),
            PopupMenuItem(value: 90, child: Text('last_90_days'.tr())),
          ],
      icon: const Icon(Icons.calendar_today_outlined),
    );
  }
}
