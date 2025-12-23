import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../logic/theme_cubit.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        return SwitchListTile(
          secondary: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: AppTheme.primaryColor,
          ),
          title: Text('dark_mode'.tr()),
          subtitle: Text(
            isDark ? 'dark_theme_enabled'.tr() : 'light_theme_enabled'.tr(),
          ),
          value: isDark,
          onChanged: (_) {
            context.read<ThemeCubit>().toggleTheme();
          },
        );
      },
    );
  }
}
