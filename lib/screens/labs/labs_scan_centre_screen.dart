import 'package:flutter/material.dart';

class LabsScanCentreScreen extends StatelessWidget {
  const LabsScanCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labs & Scan Centres'),
        backgroundColor: const Color(0xFF004B95),
      ),
      body: Center(
        child: Text(
          'List of Labs and Scan Centres will appear here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}


