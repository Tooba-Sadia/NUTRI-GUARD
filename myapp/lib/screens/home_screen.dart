import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cameraStatus = 'Not checked';
  bool _isChecking = false;

  Future<void> _checkCameras() async {
    setState(() {
      _isChecking = true;
      _cameraStatus = 'Checking cameras...';
    });

    try {
      final availableCams = await availableCameras();
      if (availableCams.isNotEmpty) {
        cameras = availableCams;
        setState(() {
          _cameraStatus = 'Found ${cameras.length} cameras';
        });
      } else {
        setState(() {
          _cameraStatus = 'No cameras found';
        });
      }
    } catch (e) {
      setState(() {
        _cameraStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriGuard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.bottomNav),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to NutriGuard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Camera Status:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _cameraStatus,
                        style: TextStyle(
                          fontSize: 16,
                          color: _cameraStatus.contains('Error') || _cameraStatus.contains('No cameras')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isChecking ? null : _checkCameras,
                        child: _isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Check Cameras'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Open Camera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  minimumSize: const Size(200, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
