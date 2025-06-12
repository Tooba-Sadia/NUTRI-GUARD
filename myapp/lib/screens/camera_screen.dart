// lib/screens/camera_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // ignore: unused_element
  Future<void> _captureImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      //xfile is used with image / file picker
      final XFile? image = await _picker.pickImage(
        
        source: ImageSource.camera, //can be gallery or camera
        imageQuality: 100, //100 perc
      );

      if (image != null) {
        final String imagePath = image.path;
        // Encode the image path to make it URL-safe eg space to %20
        final String encodedPath = Uri.encodeComponent(imagePath);

        debugPrint('🪻🪻🪻🪻🪻🪻🪻🪻🪻🪻Captured image path: $imagePath');
        debugPrint('🪻🪻🪻🪻🪻🪻🪻🪻🪻🪻Encoded path: $encodedPath');

        if (!mounted) return;
        // Navigate to the image view screen with the encoded path
        context.go('${AppRoutes.imageView}/$encodedPath');
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> pickAndCropImage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.green,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Image',
            ),
          ],
        );

        if (croppedFile != null) {
          final String croppedPath = croppedFile.path;
          final String encodedPath = Uri.encodeComponent(croppedPath);
          if (!mounted) return;
          context.go('${AppRoutes.imageView}/$encodedPath');
        }
      }
    } catch (e) {
      debugPrint('Error capturing or cropping image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing or cropping image: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Scan Food Label',
          style: AppTheme.headingStyle,
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,// Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home), // Redirect to Home
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Tap to scan food label',
                      style: AppTheme.subheadingStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: pickAndCropImage, // <-- use the cropper-enabled method
                      style: AppTheme.primaryButtonStyle,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        child: Text(
                          'Take Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
