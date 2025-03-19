// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../main.dart'; // Importing the cameras list from main.dart
import '../screens/image_view_page.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool _isCameraInitialized = false;
  String? _error;
  XFile? imageFile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _takePicture();
  }

  Future<void> _initializeCamera() async {
    final CameraDescription camera =
        cameras.length > 1 ? cameras[0] : cameras.first;

    controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      setState(() {
        _error = 'Failed to initialize camera.';
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _takePicture() async {
    try {
      setState(() {
        _isProcessing = true;
      });
      final XFile picture = await controller.takePicture();
      setState(() {
        imageFile = picture;
      });

      // Get the temporary directory path
      final directory = await getTemporaryDirectory();
      final String imagePath = '${directory.path}/captured_image.jpg';

      // Copy the image to the temporary directory
      await File(picture.path).copy(imagePath);

      // Navigate to image view screen with the saved image path
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewPage(imagePath: imagePath),
        ),
      );
    } catch (e) {
      debugPrint("Error taking picture: $e");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera View')),
        body: Center(
          child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera View')),
      body: Stack(
        children: [
          // Camera preview with correct aspect ratio
          Center(
            child: AspectRatio(
              aspectRatio:
                  1 / controller.value.aspectRatio, // Inverse the aspect ratio
              child: CameraPreview(controller),
            ),
          ),
          // Camera button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _isProcessing ? null : _takePicture,
                backgroundColor: Colors.white,
                elevation: 8,
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.camera,
                        color: Colors.black,
                        size: 40,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
