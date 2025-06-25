import 'package:flutter/material.dart';

import 'booking_screen.dart';

class OnlineProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final String connectionType;
  final String doctorId;

  const OnlineProfileScreen({
    super.key,
    required this.doctorData,
    required this.connectionType,
    required this.doctorId,
  });

  @override
  State<OnlineProfileScreen> createState() => _OnlineProfileScreenState();
}

class _OnlineProfileScreenState extends State<OnlineProfileScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<String> onlineConnectionTypes = [
    'Audio call',
    'Video call',
    'Recorded video',
  ];
  String? selectedConnectionType;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.doctorData['name'] ?? 'Unknown';
    final price = widget.doctorData['price'] ?? 0;
    final specialization = widget.doctorData['specialization'] ?? 'N/A';
    final isOnline = widget.connectionType.toLowerCase() == 'online';

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'GoiaDisplayVariable',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60)),
                  const SizedBox(height: 12),
                  Text(
                    'Dr. $name',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    specialization,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
              ),
            ),

            
            if (isOnline) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedConnectionType,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  labelText: 'Connection type',
                ),
                items:
                    onlineConnectionTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedConnectionType = value;
                  });
                },
              ),
            ],

            
            TextFormField(
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText:
                    _selectedDate == null
                        ? 'Choose appointment date'
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            
            TextFormField(
              readOnly: true,
              onTap: _pickTime,
              decoration: InputDecoration(
                labelText:
                    _selectedTime == null
                        ? 'Choose appointment time'
                        : _selectedTime!.format(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Price: EGY $price',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                if (_selectedDate == null ||
                    (isOnline && selectedConnectionType == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a date and connection type'),
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
                          appointmentDate: _selectedDate!,
                          appointmentTime: _selectedTime!,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01B5A2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Proceed to payment',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


