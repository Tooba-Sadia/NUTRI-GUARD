import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/bottom_nav.dart';
import '../screens/recipe_screen.dart';
import '../screens/bp_monitor_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/ai_processing_screen.dart';
import '../screens/image_view_page.dart';

class AppRoutes {
  static const home = '/';
  static const camera = '/camera';
  static const bottomNav = '/bottom-nav';
  static const recipe = '/recipe';
  static const bpMonitor = '/bp-monitor';
  static const settings = '/settings';
  static const aiProcessing = '/ai-processing';
  static const imageView = '/image-view';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.bottomNav, // Start with bottom navigation
    routes: [
      // Bottom navigation as the main route
      GoRoute(
        path: AppRoutes.bottomNav,
        builder: (context, state) => const BottomNavScreen(),
      ),
      // Individual screen routes
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.camera,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: AppRoutes.recipe,
        builder: (context, state) => RecipeRecommendationScreen(),
      ),
      GoRoute(
        path: AppRoutes.bpMonitor,
        builder: (context, state) => const BPMonitorScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
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
          onPressed: () => context.go(AppRoutes.bottomNav),
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
              onPressed: () => context.go(AppRoutes.bottomNav),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
