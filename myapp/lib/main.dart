import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart'; // Ensure this import is present for Provider
import 'routes/app_router.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'theme/themenotifier.dart';
import 'state/user_state.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  // Ensure Flutter is properly initialized before doing anything
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add this line to give the Flutter engine time to fully initialize
  await Future.delayed(const Duration(milliseconds: 500));
  
  try {
    // First camera initialization attempt
    print('First attempt to get cameras...');
    try {
      cameras = await availableCameras();
      print('First attempt found ${cameras.length} cameras');
    } catch (e) {
      print('First attempt failed: $e');
      
      // Wait a moment and try again
      await Future.delayed(const Duration(seconds: 1));
      
      try {
        print('Second attempt to get cameras...');
        cameras = await availableCameras();
        print('Second attempt found ${cameras.length} cameras');
      } catch (e) {
        print('Second attempt failed: $e');
        cameras = [];
      }
    }
  } catch (e) {
    print('Error during camera initialization: $e'); 
    cameras = [];
  }
  
  // Run the app after all initialization attempts
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        // ...other providers...
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeMode, _) {
        print('Rebuilding app with theme: $themeMode');
        return MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
          title: 'NutriGuard',
        );
      },
    );
  }
}
