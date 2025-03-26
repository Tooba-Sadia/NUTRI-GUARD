// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../screens/image_view_page.dart';

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

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewPage(imagePath: imagePath),
            ),
          );
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
      appBar: AppBar(title: const Text('Camera')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _captureImage,
          child: const Text('Capture Image'),
        ),
      ),
    );
  }
}
