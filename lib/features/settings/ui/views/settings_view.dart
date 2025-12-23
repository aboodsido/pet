import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../widgets/export_tile.dart';
import '../widgets/language_tile.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/theme_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionHeader(title: 'data_management'.tr()),
          const ExportTile(),
          const Divider(),
          SettingsSectionHeader(title: 'language'.tr()),
          const LanguageTile(),
          const Divider(),
          SettingsSectionHeader(title: 'appearance'.tr()),
          const ThemeTile(),
          const Divider(),
          SettingsSectionHeader(title: 'app_info'.tr()),
          _buildAppInfoTiles(),
        ],
      ),
    );
  }

  Widget _buildAppInfoTiles() {
    return Column(
      children: [
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
    );
  }
}
