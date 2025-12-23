import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transactions/logic/transaction_cubit.dart';
import '../../../transactions/logic/transaction_state.dart';

class ExportTile extends StatelessWidget {
  const ExportTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.share_outlined, color: AppTheme.primaryColor),
      title: Text('export_share'.tr()),
      subtitle: Text('export_desc'.tr()),
      onTap: () => _exportToCsv(context),
    );
  }

  Future<void> _exportToCsv(BuildContext context) async {
    final state = context.read<TransactionCubit>().state;
    if (state is! TransactionLoaded) return;

    final transactions = state.transactions;
    if (transactions.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('no_data'.tr())));
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/pet_transactions_${DateTime.now().millisecondsSinceEpoch}.csv',
      );

      String csvData = 'ID,Amount,Type,Category,Date,Note\n';
      for (var t in transactions) {
        csvData +=
            '${t.id},${t.amount},${t.type},${t.category},${t.date},${t.note ?? ""}\n';
      }

      await file.writeAsString(csvData);

      if (!context.mounted) return;

      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'My Pet App Transactions Export');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
