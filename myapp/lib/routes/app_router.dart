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

class AppRoutes {
  static const  home = '/';
  static const  camera = '/camera';
  static const  bottomNav = '/bottom-nav';
  static const  recipe = '/recipe';
  static const  bpMonitor = '/bp-monitor';
  static const  settings = '/settings';
  static const  aiProcessing = '/ai-processing';
  static const  imageView = '/image-view';
  static const  profile = '/profile';
  static const  splash = '/splash';
  static const  login = '/login'; // Add login route
  static const  signup = '/signup'; // Add signup route
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final username = extra['username'] as String?;
          final isLoggedIn = extra['isLoggedIn'] as bool? ?? false;
          return HomeScreen(username: username, isLoggedIn: isLoggedIn);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final username = extra['username'] as String?;
          final isLoggedIn = extra['isLoggedIn'] as bool? ?? false;
          return ProfileScreen(username: username, isLoggedIn: isLoggedIn);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final username = extra['username'] as String?;
          return SettingsScreen(username: username);
        },
      ),
      GoRoute(
        path: AppRoutes.bottomNav,
        builder: (context, state) => const bottom_nav.BottomNavScreen(),
      ),
      GoRoute(
        path: AppRoutes.camera,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: AppRoutes.bpMonitor,
        builder: (context, state) => const BPMonitorScreen(),
      ),
      GoRoute(
        path: AppRoutes.recipe, // Match the route here
        builder: (context, state) => const RecipeScreen(),
      ),
      // Routes with parameters
      GoRoute(
        path: '${AppRoutes.aiProcessing}/:text',
        builder: (context, state) {
          final text = state.pathParameters['text'] ?? '';
          final decodedText = Uri.decodeComponent(text);
          return AIProcessingScreen(
            text: decodedText,
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.imageView}/:path',
        builder: (context, state) {
          final path = state.pathParameters['path'] ?? '';
          final decodedPath = Uri.decodeComponent(path);
          print('Decoded image path: $decodedPath');
          return ImageViewPage(
            imagePath: decodedPath,
          );
        },
      ),
    ],
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
