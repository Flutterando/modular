import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:example/core/state/theme_controller.dart';
import '../viewmodels/settings_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark theme'),
            subtitle: const Text('App-scoped state, above the MaterialApp'),
            // ThemeController is provided by ModularApp, above the MaterialApp;
            // a page below it still reaches it through the element tree.
            value: context.watch<ThemeController>().mode == ThemeMode.dark,
            onChanged: (_) => context.read<ThemeController>().toggle(),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Unlock secret area'),
            subtitle: const Text('Flips the AppSession flag the guard reads'),
            value: settings.unlocked,
            onChanged: settings.setUnlocked,
          ),
          ListTile(
            title: const Text('Open secret area'),
            trailing: const Icon(Icons.lock_open),
            // Relative push: from `/home/settings` → `/home/settings/secret`.
            // Redirected back here by the guard while locked.
            onTap: () => context.pushNamed('./secret'),
          ),
        ],
      ),
    );
  }
}
