import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'booking_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String doctorId;
  final String connectionType;

  const ProfileScreen({
    super.key,
    required this.doctorId,
    required this.connectionType,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? doctorData;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedConnectionType;

  final List<String> connectionOptions = [
    'Audio call',
    'Video call',
    'Recorded video',
  ];

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
      setState(() => doctorData = doc.data());
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (doctorData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isOnline = widget.connectionType.toLowerCase() == 'online';
    final name = doctorData!['name'] ?? 'Unknown';
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
            const SizedBox(height: 50),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'GoiaDisplayVariable',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/doctor_avatar.png'),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(specialization),
            const SizedBox(height: 20),

            if (isOnline)
              DropdownButtonFormField<String>(
                value: selectedConnectionType,
                isExpanded: true,
                items:
                    connectionOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Connection type',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() => selectedConnectionType = value);
                },
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text(
                selectedDate != null
                    ? 'Date: ${selectedDate!.toLocal().toString().split(" ")[0]}'
                    : 'Choose appointment date',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text(
                selectedTime != null
                    ? 'Time: ${selectedTime!.format(context)}'
                    : 'Choose appointment time',
              ),
            ),
            const SizedBox(height: 12),
            Text('Price: EGY $price', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (selectedDate == null ||
                    selectedTime == null ||
                    (isOnline && selectedConnectionType == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BookingScreen(
                          doctorId: widget.doctorId,
                          doctorName: name,
                          specialization: specialization,
                          price: price,
                          connectionType:
                              isOnline
                                  ? selectedConnectionType!
                                  : widget.connectionType,
                          appointmentDate: selectedDate!,
                          appointmentTime: selectedTime!,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004B95),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
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
}


