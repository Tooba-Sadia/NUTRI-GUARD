import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _waterNotifications = true;
  bool _smartwatchSync = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: AppTheme.headingStyle,
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.bottomNav),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: AppTheme.subheadingStyle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: 'Water Reminders',
                description: 'Get notified to drink water throughout the day',
                icon: Icons.water_drop_rounded,
                trailing: Switch(
                  value: _waterNotifications,
                  onChanged: (value) {
                    setState(() {
                      _waterNotifications = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Device Integration',
                style: AppTheme.subheadingStyle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: 'Smartwatch Sync',
                description: 'Sync health data with your smartwatch',
                icon: Icons.watch_rounded,
                trailing: Switch(
                  value: _smartwatchSync,
                  onChanged: (value) {
                    setState(() {
                      _smartwatchSync = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'About',
                style: AppTheme.subheadingStyle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: 'App Version',
                description: '1.0.0',
                icon: Icons.info_outline_rounded,
                onTap: () {
                  // Show version info dialog
                },
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: 'Privacy Policy',
                description: 'Read our privacy policy',
                icon: Icons.privacy_tip_rounded,
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: 'Terms of Service',
                description: 'Read our terms of service',
                icon: Icons.description_rounded,
                onTap: () {
                  // Navigate to terms of service
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String description,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.textSecondaryColor,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
