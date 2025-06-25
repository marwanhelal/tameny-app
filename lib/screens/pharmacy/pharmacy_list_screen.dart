import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PharmacyListScreen extends StatelessWidget {
  const PharmacyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004B95),
        title: const Text('Pharmacies'),
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
              FirebaseFirestore.instance.collection('pharmacies').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final pharmacies = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final data = pharmacies[index].data() as Map<String, dynamic>;
                return Card(
                  color: Colors.white.withOpacity(0.95),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        data['logo'] ?? 'assets/pharmacies/default.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(data['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${data['city'] ?? 'City'}, ${data['address'] ?? 'Address'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/pharmacyProfile',
                          arguments: {
                            'pharmacyId': pharmacies[index].id,
                            'pharmacyData': data,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004B95),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Info',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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


