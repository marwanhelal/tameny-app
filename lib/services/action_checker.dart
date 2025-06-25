import 'package:flutter/material.dart';

class ActionChecker {
  static final Map<String, String> actionRoutes = {
    'doctor dashboard': '/doctor_dashboard',
    'patient dashboard': '/patient_dashboard',
    'online doctors': '/onlineDoctors',
    'reservations search': '/reservations_search',
    'book a doctor': '/reservations_search',
    'orders reservations': '/orders_reservations',
    'labs scan centre': '/labs_scan_centre',
    'chatbot': '/chatbot',
  };

  static final List<String> triggerPhrases = [
    'go to',
    'take me to',
    'open',
    'show me',
    'launch',
  ];

  static bool checkAndTrigger(BuildContext context, String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    for (var entry in actionRoutes.entries) {
      for (var trigger in triggerPhrases) {
        if (lowerMessage.contains(trigger) &&
            lowerMessage.contains(entry.key)) {
          Navigator.pushNamed(context, entry.value);
          print('✅ Triggered navigation to: ${entry.value}');
          return true;
        }
      }
    }

    print('❌ No app action triggered.');
    return false;
  }
}


