import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpcomingAppointmentsCard extends StatelessWidget {
  const UpcomingAppointmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('bookings')
                      .where('doctorId', isEqualTo: currentUserId)
                      .where(
                        'appointmentDate',
                        isGreaterThanOrEqualTo: DateTime.now(),
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

                final appointments = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final data =
                        appointments[index].data() as Map<String, dynamic>;
                    final patientId = data['patientId'] ?? 'Unknown';
                    final date =
                        data['appointmentDate']?.toDate()?.toString().split(
                          ' ',
                        )[0] ??
                        '';
                    final time = data['appointmentTime'] ?? '';
                    final type = data['connectionType'] ?? 'N/A';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_note),
                      title: Text('Patient ID: $patientId'),
                      subtitle: Text('📅 $date at 🕒 $time\nConnection: $type'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


