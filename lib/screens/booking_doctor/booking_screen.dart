import 'package:flutter/material.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialization;
  final int price;
  final String connectionType;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;

  const BookingScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.price,
    required this.connectionType,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.appointmentDate.toLocal().toString().split(' ')[0];
    final timeStr = widget.appointmentTime.format(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Confirm your appointment',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'GoiaDisplayVariable',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                _buildInfoCard("Doctor's name", widget.doctorName),
                _buildInfoCard("Specialization", widget.specialization),
                _buildInfoCard("Appointment Date", dateStr),
                _buildInfoCard("Appointment Time", timeStr),
                _buildInfoCard("Connection type", widget.connectionType),
                _buildInfoCard("Price", "EGY ${widget.price}"),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email address",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid email'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PaymentScreen(
                              doctorData: {
                                'userId': widget.doctorId,
                                'name': widget.doctorName,
                                'specialization': widget.specialization,
                                'price': widget.price,
                                'email': email,
                              },
                              connectionType: widget.connectionType,
                              appointmentDate: widget.appointmentDate,
                              appointmentTime: widget.appointmentTime,
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
                    'Proceed to payment',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}


