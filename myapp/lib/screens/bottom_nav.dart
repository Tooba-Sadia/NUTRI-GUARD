import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  // Define the routes for each tab
  final List<String> _routes = [
    AppRoutes.home,
    AppRoutes.camera,
    AppRoutes.recipe,
    AppRoutes.bpMonitor,
    AppRoutes.settings,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the selected route
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.backgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'Select a tab from the bottom navigation bar',
            style: AppTheme.bodyStyle,
          ),
        ),
      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
