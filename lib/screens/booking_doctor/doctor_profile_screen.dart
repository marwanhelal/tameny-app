import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'complete_reservation_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorId;

  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  Map<String, dynamic>? doctorData;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .get();
    if (doc.exists) {
      setState(() {
        doctorData = doc.data();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (doctorData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final doctorName = doctorData!['name'] ?? 'Unknown';
    final price = doctorData!['price'] ?? 0;
    final specialization = doctorData!['specialization'] ?? 'N/A';

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
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
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'GoiaDisplayVariable',
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/doctor_avatar.png'),
            ),
            const SizedBox(height: 20),
            Text(
              doctorName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(specialization),
            const SizedBox(height: 30),
            _buildDateTimePickers(),
            const SizedBox(height: 20),
            Text('Price: EGY $price', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (selectedDate != null && selectedTime != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CompleteReservationScreen(
                            doctorId: widget.doctorId,
                            doctorName: doctorName,
                            price: price,
                            specialization: specialization,
                            appointmentDate: selectedDate!,
                            appointmentTime: selectedTime!,
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both date and time'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004B95),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickDate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            selectedDate != null
                ? 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                : 'Choose appointment date',
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickTime,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            selectedTime != null
                ? 'Time: ${selectedTime!.format(context)}'
                : 'Choose appointment time',
          ),
        ),
      ],
    );
  }
}


