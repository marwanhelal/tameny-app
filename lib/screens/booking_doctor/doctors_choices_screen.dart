import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart'; 

class DoctorsChoicesScreen extends StatelessWidget {
  final String specialization;
  final String connectionTypeFilter; 

  const DoctorsChoicesScreen({
    super.key,
    required this.specialization,
    required this.connectionTypeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Select Doctor',
              style: TextStyle(
                fontFamily: 'GoiaDisplayVariable',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('doctors')
                        .where('approvalStatus', isEqualTo: 'approved')
                        .where('specialization', isEqualTo: specialization)
                        .where(
                          'connectionTypes',
                          arrayContains: connectionTypeFilter,
                        )
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No doctors available.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final doctors = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final data =
                          doctors[index].data() as Map<String, dynamic>;
                      final doctorId = doctors[index].id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                              'assets/doctor_avatar.png',
                            ), 
                          ),
                          title: Text(
                            data['name'] ?? 'Unknown Doctor',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Specialization: ${data['specialization'] ?? 'N/A'}\n'
                            'Price: ${data['price']?.toString() ?? 'N/A'} EGP',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProfileScreen(
                                      doctorId: doctorId,
                                      connectionType: connectionTypeFilter,
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
          ],
        ),
      ),
    );
  }
}


