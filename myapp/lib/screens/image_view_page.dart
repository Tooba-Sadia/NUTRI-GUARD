import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

class ImageViewPage extends StatefulWidget {
  final String imagePath;

  const ImageViewPage({super.key, required this.imagePath});

  @override
  ImageViewPageState createState() => ImageViewPageState();
}

class ImageViewPageState extends State<ImageViewPage> {
  String _recognizedText = '';
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      debugPrint('Processing image: ${widget.imagePath}');

      final file = File(widget.imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final inputImage = InputImage.fromFile(file);
      debugPrint('Created InputImage from file');

      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      debugPrint('Created text recognizer');

      final recognizedText = await textRecognizer.processImage(inputImage);
      debugPrint('OCR completed. Text: ${recognizedText.text}');

      if (mounted) {
        setState(() {
          _recognizedText = recognizedText.text;
          _isProcessing = false;
        });
      }

      textRecognizer.close();
    } catch (e) {
      debugPrint('Error processing image: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isProcessing = false;
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
          'Scan Results',
          style: AppTheme.headingStyle,
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.bottomNav),
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
        child: _isProcessing
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error processing image',
                          style: AppTheme.subheadingStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _processImage,
                          style: AppTheme.primaryButtonStyle,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recognized Text',
                                style: AppTheme.subheadingStyle.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _recognizedText.isEmpty
                                    ? 'No text was recognized'
                                    : _recognizedText,
                                style: AppTheme.bodyStyle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            final encodedText =
                                Uri.encodeComponent(_recognizedText);
                            context
                                .go('${AppRoutes.aiProcessing}/$encodedText');
                          },
                          style: AppTheme.accentButtonStyle,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'Analyze with AI',
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
