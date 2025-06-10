import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/bottom_nav.dart' as bottom_nav;
import '../screens/recipe_screen.dart';
import '../screens/bp_monitor_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/ai_processing_screen.dart';
import '../screens/image_view_page.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart' as splash; 
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';

// Route names for easy reference throughout the app
class AppRoutes {
  static const home = '/';
  static const camera = '/camera';
  static const bottomNav = '/bottom-nav';
  static const recipe = '/recipe';
  static const bpMonitor = '/bp-monitor';
  static const settings = '/settings';
  static const aiProcessing = '/ai-processing';
  static const imageView = '/image-view';
  static const profile = '/profile';
  static const splash = '/splash';
  static const login = '/login'; // Login route
  static const signup = '/signup'; // Signup route
}

// Main router configuration for the app
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/', // Set the initial route
    routes: [
      // Home route
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {}; // Get extra data if passed
          final username = extra['username'] as String?;
          final isLoggedIn = extra['isLoggedIn'] as bool? ?? false;
          return HomeScreen(username: username, isLoggedIn: isLoggedIn);
        },
      ),
      // Profile route
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final username = extra['username'] as String?;
          return ProfileScreen(username: username, isLoggedIn: false,);
        },
      ),
      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Signup route
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // Settings route
      GoRoute(
        path: '/settings',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final username = extra['username'] as String?;
          return SettingsScreen(username: username);
        },
      ),
      // Bottom navigation route
      GoRoute(
        path: AppRoutes.bottomNav,
        builder: (context, state) => const bottom_nav.BottomNavScreen(),
      ),
      // Camera route
      GoRoute(
        path: AppRoutes.camera,
        builder: (context, state) => const CameraScreen(),
      ),
      // Blood pressure monitor route
      GoRoute(
        path: AppRoutes.bpMonitor,
        builder: (context, state) => const BPMonitorScreen(),
      ),
      // Recipe route
      GoRoute(
        path: AppRoutes.recipe, // Recipe screen route
        builder: (context, state) => const RecipeScreen(),
      ),
      // AI Processing route with parameter (text)
            GoRoute(
        path: AppRoutes.aiProcessing,
        builder: (context, state) {
          // Get optional query parameters
          final text = state.uri.queryParameters['text'] ?? '';
          return AIProcessingScreen(text: text);
        },
),
      // Image View route with parameter (path)
      GoRoute(
        path: '${AppRoutes.imageView}/:path', // Route expects a path parameter
        builder: (context, state) {
          final path = state.pathParameters['path'] ?? ''; // Get the path parameter from the route
          final decodedPath = Uri.decodeComponent(path); // Decode the image path
          debugPrint('🌼🌼🌼🌼🌼🌼🌼🌼Decoded image path: $decodedPath');
          return ImageViewPage(
            imagePath: decodedPath,
          );
        },
      ),
    ],
    // Error page for unknown routes
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home), // Redirect to Home
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Path: ${state.uri.path}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home), // Redirect to Home
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
