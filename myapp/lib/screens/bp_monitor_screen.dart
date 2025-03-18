import 'package:flutter/material.dart';

class BPMonitorScreen extends StatelessWidget {
  const BPMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure Monitor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           const  Text(
              'Current BP Readings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Systolic: 120 mmHg', style: TextStyle(fontSize: 18)),
                    Text('Diastolic: 80 mmHg', style: TextStyle(fontSize: 18)),
                    Text('Pulse: 72 bpm', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call AI model or API to fetch BP data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fetching latest BP data...')),
                );
              },
              child: const Text('Fetch Latest Data'),
            ),
          ],
        ),
      ),
    );
  }
}
