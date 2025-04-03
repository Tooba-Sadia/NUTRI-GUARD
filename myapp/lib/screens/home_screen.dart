import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cameraStatus = 'Not checked';
  bool _isChecking = false;

  Future<void> _checkCameras() async {
    setState(() {
      _isChecking = true;
      _cameraStatus = 'Checking cameras...';
    });

    try {
      final availableCams = await availableCameras();
      if (availableCams.isNotEmpty) {
        cameras = availableCams;
        setState(() {
          _cameraStatus = 'Found ${cameras.length} cameras';
        });
      } else {
        setState(() {
          _cameraStatus = 'No cameras found';
        });
      }
    } catch (e) {
      setState(() {
        _cameraStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Welcome to NutriGuard',
                  style: AppTheme.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your personal nutrition assistant',
                  style: AppTheme.subheadingStyle.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                _buildFeatureCard(
                  context,
                  'Scan Food Labels',
                  'Take a photo of food labels to analyze nutritional content',
                  Icons.camera_alt_rounded,
                  AppRoutes.camera,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  'Recipe Recommendations',
                  'Get personalized recipe suggestions based on your preferences',
                  Icons.restaurant_rounded,
                  AppRoutes.recipe,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  'BP Monitor',
                  'Track and monitor your blood pressure readings',
                  Icons.health_and_safety_rounded,
                  AppRoutes.bpMonitor,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  'Settings',
                  'Customize your app preferences and notifications',
                  Icons.settings_rounded,
                  AppRoutes.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String route,
  ) {
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
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.subheadingStyle.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textSecondaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
