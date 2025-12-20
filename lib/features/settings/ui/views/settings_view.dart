import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';
import 'package:share_plus/share_plus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(
              Icons.share_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Export & Share CSV'),
            subtitle: const Text('Export transactions and open share sheet'),
            onTap: () => _exportToCsv(context),
          ),
          const Divider(),
          _buildSectionHeader('App Info'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Built with Flutter'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _exportToCsv(BuildContext context) async {
    final state = context.read<TransactionCubit>().state;
    if (state is! TransactionLoaded) return;

    final transactions = state.transactions;
    if (transactions.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
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
      // Using Share.shareXFiles which is the modern recommended way in most recent versions
      // even if analyzer complains about deprecation of 'Share' class in some environments,
      // the static method is usually the one to use.
      await Share.shareXFiles([xFile], text: 'My Pet App Transactions Export');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
