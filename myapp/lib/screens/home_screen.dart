import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../routes/app_router.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../state/user_state.dart';
// import 'home_screen.dart';
import 'camera_screen.dart';
import 'recipe_screen.dart';
import 'bp_monitor_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? username;
  final bool isLoggedIn;

  const HomeScreen({super.key, required this.username, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                userState.isLoggedIn && userState.username != null
                    ? userState.username!
                    : 'Not logged in',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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

                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  'Profile',
                  'log in to your account',
                  Icons.person_rounded,
                  AppRoutes.profile,
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

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(username: null, isLoggedIn: false),
    const CameraScreen(),
    const RecipeScreen(),
    const BPMonitorScreen(),
    const SettingsScreen(),
    ProfileScreen(username: 'Guest', isLoggedIn: false,),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for a query parameter to set the selected tab
    final queryParams = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (queryParams.contains('tab=')) {
      final tabIndex = int.tryParse(queryParams.split('tab=')[1]) ?? 0;
      setState(() {
        _selectedIndex = tabIndex;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_rounded),
            label: 'BP Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
