import 'package:flutter/material.dart';
import '../dashboards/patient_dashboard_screen.dart';

class PharmacyOrderDoneScreen extends StatelessWidget {
  const PharmacyOrderDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order confirmed!")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("✔️ Done confirmed sent to your email."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientDashboardScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("Back to home"),
            ),
          ],
        ),
      ),
    );
  }
}


