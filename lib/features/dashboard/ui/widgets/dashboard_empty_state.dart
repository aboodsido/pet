import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'no_transactions'.tr(),
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
