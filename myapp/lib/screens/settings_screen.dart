import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isWaterNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.bottomNav),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Enable Water Break Notifications'),
            trailing: Switch(
              value: isWaterNotificationEnabled,
              onChanged: (bool value) {
                setState(() {
                  isWaterNotificationEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Water Break Notifications Enabled'
                          : 'Water Break Notifications Disabled',
                    ),
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Sync with Smartwatch'),
            trailing: const Icon(Icons.sync),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing with smartwatch...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
