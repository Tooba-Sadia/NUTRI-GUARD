import 'package:flutter/material.dart';

class AIIntegrationScreen extends StatelessWidget {
  const AIIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyze Your Health Data with AI',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Click the button below to run AI-based analysis on your recent data.',
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Placeholder for AI integration logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Analyzing data using AI...'),
                    ),
                  );
                },
                icon: const Icon(Icons.memory),
                label: const Text('Run AI Analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
