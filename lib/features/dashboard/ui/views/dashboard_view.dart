import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';

import '../widgets/dashboard_body.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('app_name'.tr())),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            return RefreshIndicator(
              onRefresh:
                  () async =>
                      context.read<TransactionCubit>().loadTransactions(),
              child: DashboardBody(state: state),
            );
          }
          return Center(child: Text('add_first_transaction'.tr()));
        },
      ),
    );
  }
}
