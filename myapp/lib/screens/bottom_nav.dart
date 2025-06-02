import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart'; // Import your screens
import 'camera_screen.dart';
import 'recipe_screen.dart';
import 'bp_monitor_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  // Define the screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const CameraScreen(),
    const RecipeScreen(),
    const BPMonitorScreen(),
    const SettingsScreen(),
    ProfileScreen(username: 'YourUsername', isLoggedIn: true), // Replace with actual username and login status
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Dynamically display the selected screen
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_rounded,
                  size: 24,
                ),
                activeIcon: Icon(
                  Icons.home_rounded,
                  size: 28,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.camera_alt_rounded,
                  size: 24,
                ),
                activeIcon: Icon(
                  Icons.camera_alt_rounded,
                  size: 28,
                ),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.restaurant_rounded,
                  size: 24,
                ),
                activeIcon: Icon(
                  Icons.restaurant_rounded,
                  size: 28,
                ),
                label: 'Recipes',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.health_and_safety_rounded,
                  size: 24,
                ),
                activeIcon: Icon(
                  Icons.health_and_safety_rounded,
                  size: 28,
                ),
                label: 'BP Monitor',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings_rounded,
                  size: 24,
                ),
                activeIcon: Icon(
                  Icons.settings_rounded,
                  size: 28,
                ),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_rounded,
                  size: 24,
                ),
                activeIcon: Icon(
                  Icons.person_rounded,
                  size: 28,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToBottomNav();
  }

  Future<void> _navigateToBottomNav() async {
    // Simulate a delay for the splash screen
    await Future.delayed(const Duration(seconds: 3));
    // Navigate to the BottomNavScreen
    context.go(AppRoutes.bottomNav);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Image.asset(
          'assets/app_icon.png', // Replace with your logo file path
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: const Center(
        child: Text('Welcome to the Recipe Screen!'),
      ),
    );
  }
}



