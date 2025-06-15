import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart'; // Provider for state management
import 'routes/app_router.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'theme/themenotifier.dart';
import 'state/user_state.dart';
import 'utils/tflite.dart';

// Global list to hold available cameras
List<CameraDescription> cameras = [];

Future<void> main() async {
  // Ensure Flutter bindings are initialized before any async code
  WidgetsFlutterBinding.ensureInitialized();

  

  // Give the engine a moment to finish initializing
  await Future.delayed(const Duration(milliseconds: 500));
  
  try {
    // First attempt to get available cameras
    print('First attempt to get cameras...');
    try {
      cameras = await availableCameras();
      print('First attempt found ${cameras.length} cameras');
    } catch (e) {
      print('First attempt failed: $e');
      
      // Wait a moment and try again if the first attempt fails
      await Future.delayed(const Duration(seconds: 1));
      
      try {
        print('Second attempt to get cameras...');
        cameras = await availableCameras();
        print('Second attempt found ${cameras.length} cameras');
      } catch (e) {
        print('Second attempt failed: $e');
        cameras = []; // Set to empty if both attempts fail
      }
    }
  } catch (e) {
    print('Error during camera initialization: $e'); 
    cameras = []; // Set to empty if any error occurs
  }
  
  // Run the main app with providers after initialization
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()), // User state provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes and rebuild the app accordingly
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeMode, _) {
        print('Rebuilding app with theme: $themeMode');
        return MaterialApp.router(
          debugShowCheckedModeBanner: false, // <--- Add this line

          theme: AppTheme.lightTheme, // Light theme
          darkTheme: AppTheme.darkTheme, // Dark theme
          themeMode: themeMode, // Current theme mode
          routerConfig: AppRouter.router, // App routes
          title: 'NutriGuard', // App title
        );
      },
    );
  }
}
