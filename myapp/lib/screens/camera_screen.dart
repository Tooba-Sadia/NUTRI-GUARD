// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
      final XFile picture = await controller.takePicture();
      setState(() {
        imageFile = picture;
      });

      // Navigate to image view screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewPage(imagePath: imageFile!.path),
        ),
      );
    } catch (e) {
      debugPrint("Error taking picture: $e");
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
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        backgroundColor: Colors.white,
        child: const Icon(Icons.camera, color: Colors.black),
      ),
    );
  }
}
