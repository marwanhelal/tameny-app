import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'confirm_lab_appointment_screen.dart';

class SelectLabScreen extends StatefulWidget {
  final String labType;
  const SelectLabScreen({super.key, required this.labType});

  @override
  State<SelectLabScreen> createState() => _SelectLabScreenState();
}

class _SelectLabScreenState extends State<SelectLabScreen> {
  String? selectedLabId;
  Map<String, dynamic>? selectedLabData;
  DateTime? selectedDateTime;
  String? userEmail;

  Future<void> pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Lab'),
        backgroundColor: const Color(0xFF01B5A2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('labs_centres')
                      .where('type', isEqualTo: widget.labType)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No labs found for this type.');
                }

                return DropdownButtonFormField<String>(
                  value: selectedLabId,
                  hint: const Text('Choose lab'),
                  items:
                      snapshot.data!.docs.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }).toList(),
                  onChanged: (value) {
                    final labDoc = snapshot.data!.docs.firstWhere(
                      (doc) => doc.id == value,
                    );
                    setState(() {
                      selectedLabId = value;
                      selectedLabData = labDoc.data() as Map<String, dynamic>;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => pickDateTime(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDateTime == null
                    ? 'Select Date & Time'
                    : '${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} ${selectedDateTime!.hour}:${selectedDateTime!.minute.toString().padLeft(2, '0')}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01B5A2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  userEmail = value.trim();
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  (selectedLabId != null &&
                          selectedLabData != null &&
                          selectedDateTime != null &&
                          userEmail != null &&
                          userEmail!.isNotEmpty)
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ConfirmLabAppointmentScreen(
                                  labId: selectedLabId!,
                                  labName: selectedLabData!['name'],
                                  labType: widget.labType,
                                  appointmentDateTime: selectedDateTime!,
                                  userEmail: userEmail!,
                                  price:
                                      (selectedLabData!['price'] as num?)
                                          ?.toDouble() ??
                                      0.0,
                                ),
                          ),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01B5A2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Proceed to confirmation',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
