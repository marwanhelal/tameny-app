import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart'; 

class SelectDoctorScreen extends StatelessWidget {
  final String specialization;

  const SelectDoctorScreen({super.key, required this.specialization});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B95),
        title: const Text('Select Doctor'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('doctors')
                  .where('approvalStatus', isEqualTo: 'approved')
                  .where('specialization', isEqualTo: specialization)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No doctors available for this specialization.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            final doctors = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final data = doctors[index].data() as Map<String, dynamic>;
                final doctorId = doctors[index].id;
                final name = data['name'] ?? 'Unknown';
                final price = data['price']?.toString() ?? 'N/A';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        'assets/doctor_avatar.png',
                      ), 
                    ),
                    title: Text('Dr. $name'),
                    subtitle: Text(
                      'Specialization: $specialization\nPrice: $price EGP',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProfileScreen(
                                doctorId: doctorId,
                                connectionType: "Need a visit",
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}


