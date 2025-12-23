import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppTheme.primaryColor),
      title: Text('app_language'.tr()),
      subtitle: Text(
        context.locale.languageCode == 'en' ? 'English' : 'العربية',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _changeLanguage(context),
    );
  }

  Future<void> _changeLanguage(BuildContext context) async {
    final newLocale =
        context.locale.languageCode == 'en'
            ? const Locale('ar')
            : const Locale('en');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
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
  }
}
