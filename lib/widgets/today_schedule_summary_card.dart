import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodayScheduleSummaryCard extends StatefulWidget {
  const TodayScheduleSummaryCard({super.key});

  @override
  State<TodayScheduleSummaryCard> createState() =>
      _TodayScheduleSummaryCardState();
}

class _TodayScheduleSummaryCardState extends State<TodayScheduleSummaryCard> {
  bool _isVisible = true;

  int appointments = 0;
  double earnings = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTodayStats();
  }

  Future<void> _fetchTodayStats() async {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;
    if (doctorId == null) return;

    final todayStart = DateTime.now();
    final todayOnly = DateTime(
      todayStart.year,
      todayStart.month,
      todayStart.day,
    );

    final snapshot =
        await FirebaseFirestore.instance
            .collection('bookings')
            .where('doctorId', isEqualTo: doctorId)
            .where('appointmentDate', isGreaterThanOrEqualTo: todayOnly)
            .get();

    int count = 0;
    double sum = 0.0;

    for (var doc in snapshot.docs) {
      count++;
      final data = doc.data();
      final fee = (data['price'] ?? 0).toDouble();
      sum += fee;
    }

    setState(() {
      appointments = count;
      earnings = sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF01B5A2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    "Appointments",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    appointments.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    "Earnings (EGP)",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
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
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _isVisible = false),
          ),
        ),
      ],
    );
  }
}


