import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPatientsCard extends StatelessWidget {
  const MyPatientsCard({super.key});

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;
    if (doctorId == null) return [];

    
    final bookingsSnapshot =
        await FirebaseFirestore.instance
            .collection('bookings')
            .where('doctorId', isEqualTo: doctorId)
            .get();

    
    final patientIds = {
      for (var doc in bookingsSnapshot.docs)
        (doc.data()['patientId'] ?? '') as String,
    }..removeWhere((id) => id.isEmpty);

    if (patientIds.isEmpty) return [];

    
    final usersSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: patientIds.toList())
            .get();

    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final patients = snapshot.data ?? [];

        return Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Patients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                patients.isEmpty
                    ? const Text('No patients found.')
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(patient['name'] ?? 'Unknown'),
                          subtitle: Text(patient['email'] ?? ''),
                        );
                      },
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}


