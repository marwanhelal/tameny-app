import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EarningsOverviewCard extends StatelessWidget {
  const EarningsOverviewCard({super.key});

  Future<double> _calculateMonthlyEarnings() async {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;
    if (doctorId == null) return 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final query =
        await FirebaseFirestore.instance
            .collection('bookings')
            .where('doctorId', isEqualTo: doctorId)
            .where('appointmentDate', isGreaterThanOrEqualTo: startOfMonth)
            .where('appointmentDate', isLessThan: endOfMonth)
            .get();

    double total = 0;
    for (var doc in query.docs) {
      final data = doc.data();
      total += (data['price'] ?? 0).toDouble();
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final currentMonthName = _monthName(currentMonth);

    return FutureBuilder<double>(
      future: _calculateMonthlyEarnings(),
      builder: (context, snapshot) {
        final earnings = snapshot.data ?? 0.0;

        return Card(
          color: Colors.green[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Earnings Overview ($currentMonthName)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "EGP ${earnings.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}


