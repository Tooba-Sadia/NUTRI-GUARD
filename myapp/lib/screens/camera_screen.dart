// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _captureImage() async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      // Capture image using image picker
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        final String imagePath = image.path;
        
        // Debug print to verify the image path
        print('Captured image path: $imagePath');

        if (mounted) {
          // Properly encode the image path for URL
          final encodedPath = Uri.encodeComponent(imagePath);
          print('Encoded path: $encodedPath');
          
          // Use GoRouter to navigate to the image view page
          context.go('${AppRoutes.imageView}/$encodedPath');
        }
      }
    } catch (e) {
      print('Error capturing image: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.bottomNav),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _captureImage,
          child: const Text('Capture Image'),
        ),
      ),
    );
  }
}
