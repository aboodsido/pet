import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet/core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';
  final _box = Hive.box(
    AppConstants.settingsBox,
  ); // Using a dedicated box for settings

  void _loadTheme() {
    final savedTheme = _box.get(_themeKey, defaultValue: 'dark');
    emit(savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _box.put(_themeKey, newTheme == ThemeMode.dark ? 'dark' : 'light');
    emit(newTheme);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
