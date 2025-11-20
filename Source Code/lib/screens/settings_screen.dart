import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        SwitchListTile(
          value: sp.dark,
          onChanged: (v) => sp.setDark(v),
          title: const Text('Dark Mode'),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Data is stored locally on this device using SQLite. You can back up by copying the app data directory.',
          ),
        ),
      ],
    );
  }
}
