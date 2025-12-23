import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DashboardRecentHeader extends StatelessWidget {
  final VoidCallback onSeeAll;
  const DashboardRecentHeader({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'recent_transactions'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(onPressed: onSeeAll, child: Text('see_all'.tr())),
      ],
    );
  }
}
