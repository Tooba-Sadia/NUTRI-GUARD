import 'package:flutter/material.dart';

class HealthSummaryCard extends StatelessWidget {
  final String metric;
  final String value;

   const HealthSummaryCard({super.key, required this.metric, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const   EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(metric, style: const  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value, style:  const  TextStyle(fontSize: 16, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
