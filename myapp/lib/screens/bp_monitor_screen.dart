import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

class BPMonitorScreen extends StatefulWidget {
  const BPMonitorScreen({super.key});

  @override
  BPMonitorScreenState createState() => BPMonitorScreenState();
}

class BPMonitorScreenState extends State<BPMonitorScreen> {
  final List<BPReading> _readings = [
    BPReading(
      systolic: 120,
      diastolic: 80,
      pulse: 72,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BPReading(
      systolic: 118,
      diastolic: 78,
      pulse: 70,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BPReading(
      systolic: 122,
      diastolic: 82,
      pulse: 74,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'BP Monitor',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentReading(),
              const SizedBox(height: 24),
              Text(
                'History',
                style: AppTheme.subheadingStyle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildReadingsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show add reading dialog
        },
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reading'),
      ),
    );
  }

  Widget _buildCurrentReading() {
    final latestReading = _readings.first;
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Text(
            'Latest Reading',
            style: AppTheme.subheadingStyle.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildReadingValue(
                'Systolic',
                '${latestReading.systolic}',
                'mmHg',
                Icons.favorite_rounded,
              ),
              Container(
                width: 1,
                height: 60,
                color: AppTheme.textSecondaryColor.withOpacity(0.2),
              ),
              _buildReadingValue(
                'Diastolic',
                '${latestReading.diastolic}',
                'mmHg',
                Icons.favorite_rounded,
              ),
              Container(
                width: 1,
                height: 60,
                color: AppTheme.textSecondaryColor.withOpacity(0.2),
              ),
              _buildReadingValue(
                'Pulse',
                '${latestReading.pulse}',
                'bpm',
                Icons.speed_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: ${_formatDate(latestReading.timestamp)}',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingValue(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.headingStyle.copyWith(
            color: AppTheme.primaryColor,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        Text(
          unit,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _readings.length,
      itemBuilder: (context, index) {
        final reading = _readings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryLightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              '${reading.systolic}/${reading.diastolic} mmHg',
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            subtitle: Text(
              'Pulse: ${reading.pulse} bpm • ${_formatDate(reading.timestamp)}',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondaryColor,
              size: 16,
            ),
            onTap: () {
              // Show reading details
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class BPReading {
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime timestamp;

  BPReading({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.timestamp,
  });
}
