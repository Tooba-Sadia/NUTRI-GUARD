import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:myapp/screens/halal_view.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

//add img crop to this page --------------------------------------------------------------------------------------------------------------------
class ImageViewPage extends StatefulWidget {
  final String imagePath;

  const ImageViewPage({super.key, required this.imagePath});

  @override
  ImageViewPageState createState() => ImageViewPageState();
}

class ImageViewPageState extends State<ImageViewPage> {
  String _recognizedText = ''; // Holds the recognized text from the image
  bool _isProcessing = false; // Indicates if the image is being processed
  String? _error; // Holds any error message during processing

  @override
  void initState() {
    super.initState();
    _processImage(); // Start processing the image when the page loads
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true; // Show loading indicator
      _error = null; // Clear any previous errors
    });

    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin); // Initialize text recognizer

    try {
      debugPrint('Processing image: ${widget.imagePath}');

      final file = File(widget.imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found'); // Handle missing file
      }

      final inputImage = InputImage.fromFile(file); // Convert file to InputImage
      debugPrint('Created InputImage from file');

      final recognizedText = await textRecognizer.processImage(inputImage); // Perform OCR
      for (final block in recognizedText.blocks) {
        debugPrint('Block: ${block.text}');
        for (final line in block.lines) {
          debugPrint('Line: ${line.text}');
          for (final element in line.elements) {
            debugPrint('Element: ${element.text}');
          }
        }
      }
      debugPrint('Text recognition completed successfully.');
      debugPrint('OCR completed. Text: ${recognizedText.text}');

      if (mounted) {
        setState(() {
          _recognizedText = recognizedText.text; // Update recognized text
          _isProcessing = false; // Stop loading indicator
        });
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to process the image. Please try again.'; // Set error message
          _isProcessing = false; // Stop loading indicator
        });
      }
    } finally {
      textRecognizer.close(); // Ensure the recognizer is closed
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
          onPressed: () {
            context.go(AppRoutes.home); // Navigate back to the home page
          },
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
                          onPressed: _processImage, // Retry processing
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  
                            final encodedText = Uri.encodeComponent(_recognizedText); // Encode the text
                            debugPrint('Ecoded text: $encodedText');
                            context.go('${AppRoutes.aiProcessing}?text=${Uri.encodeComponent(_recognizedText)}&mode=advanced');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Check Allergens'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final encodedText = Uri.encodeComponent(_recognizedText); // Encode the text
                                  debugPrint('😀😀😀😀😀😀Encoded text: $encodedText');
                                  debugPrint('😀😀😀😀😀😀');

                                  context.push('${AppRoutes.halalView}?text=${Uri.encodeComponent(_recognizedText)}&mode=advanced');
                                  
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Check Halal Status'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}