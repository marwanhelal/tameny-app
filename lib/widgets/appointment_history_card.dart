import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentHistoryCard extends StatelessWidget {
  const AppointmentHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Appointment History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('bookings')
                      .where('doctorId', isEqualTo: doctorId)
                      .where('appointmentDate', isLessThan: DateTime.now())
                      .orderBy('appointmentDate', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No past appointments found.');
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: docs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final Timestamp timestamp = data['appointmentDate'];
                    final DateTime date =
                        timestamp.toDate(); 
                    final patientEmail = data['patientEmail'] ?? 'Unknown';
                    final connectionType = data['connectionType'] ?? 'N/A';

                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(patientEmail),
                      subtitle: Text(
                        '${date.toLocal().toString().split(' ')[0]} - $connectionType',
                      ),
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


