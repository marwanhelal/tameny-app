import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientBookingsDashboard extends StatefulWidget {
  const PatientBookingsDashboard({super.key});

  @override
  State<PatientBookingsDashboard> createState() =>
      _PatientBookingsDashboardState();
}

class _PatientBookingsDashboardState extends State<PatientBookingsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings Dashboard"),
        backgroundColor: const Color(0xFF004B95),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Doctors"),
            Tab(text: "Labs"),
            Tab(text: "Hospitals"),
            Tab(text: "Pharmacy"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          bookingsTab("bookings", "doctorName", isDoctor: true),
          bookingsTab("lab_bookings", "labName", isLab: true),
          bookingsTab("hospital_bookings", "hospitalName", isHospital: true),
          pharmacyTab(),
        ],
      ),
    );
  }

  Widget bookingsTab(
    String collection,
    String titleField, {
    bool isDoctor = false,
    bool isLab = false,
    bool isHospital = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(collection)
                .where(isDoctor ? 'patientId' : 'userId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final now = DateTime.now();

          final upcoming =
              docs
                  .where(
                    (doc) => (doc['appointmentDate'] as Timestamp)
                        .toDate()
                        .isAfter(now),
                  )
                  .toList();
          final past =
              docs
                  .where(
                    (doc) => (doc['appointmentDate'] as Timestamp)
                        .toDate()
                        .isBefore(now),
                  )
                  .toList();

          return ListView(
            children: [
              buildSection(
                "Upcoming Bookings",
                upcoming,
                titleField,
                isDoctor,
                isLab,
                isHospital,
              ),
              buildSection(
                "Past Bookings",
                past,
                titleField,
                isDoctor,
                isLab,
                isHospital,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget pharmacyTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pharmacy_orders')
                .where('userId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final pharmacy = doc['pharmacyId'];
              final total = doc['totalPrice'] ?? 0;
              final payment = doc['paymentMethod'];
              final date = (doc['orderTime'] as Timestamp).toDate();

              return customCard(
                title: "Order from: $pharmacy",
                subtitle:
                    "Date: ${date.toLocal().toString().split(' ')[0]}\nTotal: EGP $total\nPayment: $payment",
                onDelete: () => doc.reference.delete(),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildSection(
    String label,
    List<DocumentSnapshot> docs,
    String titleField,
    bool isDoctor,
    bool isLab,
    bool isHospital,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...docs.map((doc) {
          final title = doc[titleField];
          final date = (doc['appointmentDate'] as Timestamp).toDate();
          final time = doc['appointmentTime'];
          final formattedDate =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

          String extra = "";
          if (isDoctor) {
            extra =
                "Specialization: ${doc['specialization'] ?? 'N/A'}\nType: ${doc['connectionType'] ?? 'N/A'}";
          } else if (isLab) {
            extra =
                "Type: ${doc['labType'] ?? 'N/A'}\nPayment: ${doc['paymentMethod'] ?? 'N/A'}";
          } else if (isHospital) {
            extra =
                "Case: ${doc['emergencyType'] ?? 'N/A'}\nPayment: ${doc['paymentMethod'] ?? 'N/A'}";
          }

          return customCard(
            title: isDoctor ? "Dr. $title" : title,
            subtitle: "$extra\nDate: $formattedDate at $time",
            onDelete: () => doc.reference.delete(),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget customCard({
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}


