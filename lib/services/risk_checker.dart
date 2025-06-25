import 'package:flutter/material.dart';

class RiskChecker {
  static void checkAndWarn(BuildContext context, String botResponse) {
    final lowerResponse = botResponse.toLowerCase();

    if (lowerResponse.contains('severe chest pain') ||
        lowerResponse.contains('difficulty breathing') ||
        lowerResponse.contains('vision loss') ||
        lowerResponse.contains('sudden weakness')) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('⚠ Urgent Attention Needed'),
              content: const Text(
                'Based on the symptoms mentioned, we recommend seeking emergency care immediately.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}


