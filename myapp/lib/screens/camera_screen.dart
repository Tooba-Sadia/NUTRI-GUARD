// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart'; // Import cameras list
import '../screens/image_view_page.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  String? _error;
  bool _isProcessing = false;
  int _initAttempts = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('CameraScreen - initState called');
    
    // Add a delay before checking permissions and initializing camera
    Future.delayed(const Duration(milliseconds: 1000), () {
      _checkPermissionsAndInitCamera();
    });
  }

  @override
  void dispose() {
    print('CameraScreen - dispose called');
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller!.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _checkPermissionsAndInitCamera() async {
    print('Checking camera permissions...');
    var status = await Permission.camera.status;
    
    if (!status.isGranted) {
      print('Camera permission not granted, requesting...');
      status = await Permission.camera.request();
    }
    
    if (status.isGranted) {
      print('Camera permission granted, initializing camera...');
      _initializeCamera();
    } else {
      setState(() {
        _error = 'Camera permission denied. Please enable camera access in settings.';
      });
    }
  }

  Future<void> _restartApp() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please restart the app to fix camera issues')),
    );
    
    // Go back to the home screen
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _manuallySearchCameras() async {
    setState(() {
      _error = 'Searching for cameras...';
    });
    
    try {
      print('Manual camera search attempt');
      
      try {
        final availableCams = await availableCameras();
        
        if (availableCams.isNotEmpty) {
          print('Manually found ${availableCams.length} cameras');
          cameras = availableCams;
          _initializeCamera();
        } else {
          setState(() {
            _error = 'No cameras found. Please restart the app.';
          });
        }
      } catch (e) {
        if (e.toString().contains('MissingPluginException')) {
          setState(() {
            _error = 'Camera plugin not available. Please restart your phone and try again.';
          });
        } else {
          setState(() {
            _error = 'Error detecting cameras: $e';
          });
        }
      }
    } catch (e) {
      print('Error during manual camera search: $e');
      setState(() {
        _error = 'Error searching for cameras: $e';
      });
    }
  }

  Future<void> _initializeCamera() async {
    _initAttempts++;
    print('Camera initialization attempt #$_initAttempts');
    
    if (cameras.isEmpty) {
      print('No cameras available in global list');
      if (_initAttempts > 3) {
        setState(() {
          _error = 'No cameras available after multiple attempts. Please restart your device.';
        });
        return;
      }
      
      // Wait and retry
      await Future.delayed(const Duration(milliseconds: 500));
      await _manuallySearchCameras();
      return;
    }

    try {
      print('Using camera: ${cameras[0].name}');
      
      // Dispose previous controller if exists
      await controller?.dispose();
      
      // Create new controller
      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      print('Initializing controller...');
      await controller!.initialize();
      print('Controller initialized successfully');

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _error = null;
        });
      }
    } catch (e) {
      print('Camera init error: $e');
      
      if (_initAttempts < 3) {
        print('Retrying camera initialization...');
        await Future.delayed(const Duration(seconds: 1));
        _initializeCamera();
      } else {
        setState(() {
          _error = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || controller == null || !controller!.value.isInitialized) {
      print('Cannot take picture - camera not initialized');
      return;
    }

    if (_isProcessing) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      print('Taking picture...');
      final XFile picture = await controller!.takePicture();
      print('Picture taken: ${picture.path}');

      final directory = await getTemporaryDirectory();
      final String imagePath = '${directory.path}/captured_image.jpg';
      
      await File(picture.path).copy(imagePath);
      print('Picture copied to: $imagePath');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewPage(imagePath: imagePath),
          ),
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
      setState(() {
        _error = 'Failed to take picture: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _manuallySearchCameras,
                child: const Text('Search for Cameras'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _restartApp,
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Initializing camera...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Stack(
        children: [
          Center(
            child: CameraPreview(controller!),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _isProcessing ? null : _takePicture,
                backgroundColor: Colors.white,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Icon(Icons.camera_alt, color: Colors.black, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
