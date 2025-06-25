import 'package:flutter/material.dart';
import 'select_lab_screen.dart';

class LabsAndScanCentreScreen extends StatelessWidget {
  const LabsAndScanCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labs and Scan Centre')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLabTypeCard(
            context,
            'Medical analysis laboratory',
            'Book tests & diagnostic services',
          ),
          const SizedBox(height: 16),
          _buildLabTypeCard(
            context,
            'Clinics and labs',
            'Consult labs & clinic services',
          ),
        ],
      ),
    );
  }

  Widget _buildLabTypeCard(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectLabScreen(labType: title),
            ),
          );
        },
      ),
    );
  }
}
