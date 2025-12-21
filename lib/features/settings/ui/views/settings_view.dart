import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/settings/logic/theme_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_cubit.dart';
import 'package:pet/features/transactions/logic/transaction_state.dart';
import 'package:share_plus/share_plus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'data_management'.tr()),
          ListTile(
            leading: const Icon(
              Icons.share_outlined,
              color: AppTheme.primaryColor,
            ),
            title: Text('export_share'.tr()),
            subtitle: Text('export_desc'.tr()),
            onTap: () => _exportToCsv(context),
          ),
          const Divider(),
          _buildSectionHeader(context, 'language'.tr()),
          ListTile(
            leading: const Icon(Icons.language, color: AppTheme.primaryColor),
            title: Text('app_language'.tr()),
            subtitle: Text(
              context.locale.languageCode == 'en' ? 'English' : 'العربية',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final newLocale =
                  context.locale.languageCode == 'en'
                      ? const Locale('ar')
                      : const Locale('en');

              // Show a simple loading indicator to "simulate" a refresh
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        const Center(child: CircularProgressIndicator()),
              );

              await Future.delayed(const Duration(milliseconds: 600));
              if (!context.mounted) return;

              await context.setLocale(newLocale);

              if (context.mounted) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('lang_changed'.tr()),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'appearance'.tr()),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark;
              return SwitchListTile(
                secondary: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppTheme.primaryColor,
                ),
                title: Text('dark_mode'.tr()),
                subtitle: Text(
                  isDark
                      ? 'dark_theme_enabled'.tr()
                      : 'light_theme_enabled'.tr(),
                ),
                value: isDark,
                onChanged: (_) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'app_info'.tr()),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('version'.tr()),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text('built_with'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
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
