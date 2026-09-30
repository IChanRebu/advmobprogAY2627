import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_providers.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark or light theme'),
            value: themeModel.isDark,
            onChanged: (_) => themeModel.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              try {
                await UserService().signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (route) => false,
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to log out: $error')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
