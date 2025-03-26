import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'ai_processing_screen.dart';
import 'camera_screen.dart';

class ImageViewPage extends StatefulWidget {
  final String imagePath;

  const ImageViewPage({super.key, required this.imagePath});

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  String _recognizedText = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _performOCR();
  }

  Future<void> _performOCR() async {
    // First, show loading indicator
    setState(() {
      _isProcessing = true; // Set processing flag to true
    });

    try {
      // Step 1: Load the image from file path
      final inputImage = InputImage.fromFilePath(widget.imagePath);

      // Step 2: Create a text recognizer for Latin script (English)
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);

      // Step 3: Process the image and extract text
      // await means wait until text extraction is complete
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Step 4: Update the UI with extracted text
      setState(() {
        _recognizedText = recognizedText.text; // Save the extracted text
        _isProcessing = false; // Hide loading indicator
      });
    } catch (e) {
      // If any error occurs during text extraction
      setState(() {
        _recognizedText = 'Error performing OCR: $e'; // Show error message
        _isProcessing = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isProcessing ? null : _performOCR,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // you can scroll the text
        child: Column(
          //arranges the text in a column
          children: [
            //list of widgets displayed in the column
            Image.file(
              File(widget.imagePath), //file(): load an image from a file path
              fit:
                  BoxFit.contain, // BoxFit.contain: fit the image to the screen
            ),
            if (_isProcessing) //if the text is being processed, show a circular progress indicator
              const Padding(
                padding: EdgeInsets.all(
                    16.0), //padding around the circular progress indicator
                child:
                    CircularProgressIndicator(), //shows a circular loading indicator
              ),
            Padding(
              padding: const EdgeInsets.all(16.0), //padding around the text
            ),
            if (_recognizedText.isNotEmpty &&
                !_isProcessing) //loads the next button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Retake Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (mounted) {
                          // Delete the current image
                          final file = File(widget.imagePath);
                          if (await file.exists()) {
                            await file.delete();
                          }
                          // Go back to camera screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScreen(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Retake Picture'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                            Colors.grey, // Different color for retake button
                      ),
                    ),
                    const SizedBox(height: 16), // Space between buttons

                    // Existing Next Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AIProcessingScreen(
                                processedText: _recognizedText,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
