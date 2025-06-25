import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorUpcomingAppointmentsWidget extends StatelessWidget {
  const DoctorUpcomingAppointmentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDoctorId = FirebaseAuth.instance.currentUser?.uid;

    if (currentDoctorId == null) {
      return const Center(child: Text("Not logged in"));
    }

    final today = DateTime.now();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('bookings')
              .where('doctorId', isEqualTo: currentDoctorId)
              .where(
                'appointmentDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(today),
              )
              .orderBy('appointmentDate')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No upcoming appointments.');
        }

        final bookings = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...bookings.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text("Patient ID: ${data['patientId']}"),
                  subtitle: Text(
                    "Date: ${data['appointmentDate'].toDate().toLocal().toString().split(' ')[0]}\n"
                    "Time: ${data['appointmentTime']}\n"
                    "Type: ${data['connectionType']}",
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}


