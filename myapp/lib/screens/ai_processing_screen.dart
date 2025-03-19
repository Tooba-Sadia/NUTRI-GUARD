import 'package:flutter/material.dart';
import 'camera_screen.dart';

class AIProcessingScreen extends StatefulWidget {
  final String processedText;

  const AIProcessingScreen({
    super.key,
    required this.processedText,
  });

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen> {
  bool _isProcessing = false;
  String _aiResult = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _processWithAI();
  }

  Future<void> _processWithAI() async {
    setState(() {
      _isProcessing = true;
      _error = '';
    });

    try {
      // TODO: Add your AI model processing here
      // For example:
      // final result = await yourAIModel.process(widget.processedText);

      // Simulating AI processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Temporary result for demonstration
      final result =
          "AI Analysis Result:\n1. Text Length: ${widget.processedText.length} characters\n2. Word Count: ${widget.processedText.split(' ').length} words\n3. Sentiment: Positive\n4. Key Topics: Health, Nutrition";

      setState(() {
        _aiResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error processing with AI: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Processing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isProcessing ? null : _processWithAI,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Text:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.processedText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing with AI...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            if (_aiResult.isNotEmpty) ...[
              const Text(
                'AI Analysis Result:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _aiResult,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Another Picture'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
