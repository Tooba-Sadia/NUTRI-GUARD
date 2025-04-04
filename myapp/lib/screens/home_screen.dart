import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() =>
      HomeScreenState(); // Create state for HomeScreen
}

// State class for HomeScreen
class HomeScreenState extends State<HomeScreen> {
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
              AppTheme.primaryColor, // gradient Top color
              AppTheme.backgroundColor, // gradient Bottom color
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16), // Padding around the content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Welcome to NutriGuard', // Welcome message
                  style: AppTheme.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your personal nutrition assistant', // Subtitle
                  style: AppTheme.subheadingStyle.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                // Feature cards for different functionalities
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

  // Method to build feature cards
  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String route,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Card background color
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow effect
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route), // Navigate to the specified route
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16), // Padding inside the card
            child: Row(
              children: [
                // Icon for the feature
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
                const SizedBox(width: 16), // Space between icon and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, // Feature title
                        style: AppTheme.subheadingStyle.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(
                          height: 4), // Space between title and description
                      Text(
                        description, // Feature description
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon to indicate navigation
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
