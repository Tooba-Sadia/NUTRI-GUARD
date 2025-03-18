import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleCameraAccess(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      context.go('/camera'); // Navigate to camera screen
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        context.go('/camera');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied. Please allow access.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission permanently denied. Opening app settings...')),
      );
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NutriGuard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to NutriGuard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleCameraAccess(context),
              child: const Text("Start Scanning"),
            ),
          ],
        ),
      ),
    );
  }
}
