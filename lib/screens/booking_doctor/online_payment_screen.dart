import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/email_service.dart';
import '../dashboards/patient_dashboard_screen.dart';

class OnlinePaymentScreen extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final int price;
  final DateTime appointmentDate;
  final String appointmentTime;

  const OnlinePaymentScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.price,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _completePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final user = FirebaseAuth.instance.currentUser;
    final patientId = user?.uid;
    final email = user?.email ?? "";

    
    final bookingRef = await FirebaseFirestore.instance
        .collection('bookings')
        .add({
          'doctorName': widget.doctorName,
          'patientId': patientId,
          'specialization': widget.specialization,
          'price': widget.price,
          'appointmentDate': widget.appointmentDate.toIso8601String(),
          'appointmentTime': widget.appointmentTime,
          'paymentMethod': "Online",
          'status': 'confirmed',
          'createdAt': Timestamp.now(),
        });

    
    final doctorSnapshot =
        await FirebaseFirestore.instance
            .collection('doctors')
            .where('name', isEqualTo: widget.doctorName)
            .get();

    
    await EmailService.sendEmail(
      toEmail: email,
      subject: 'Online Doctor Appointment Confirmation',
      content:
          '''Your online appointment with Dr. ${widget.doctorName} (${widget.specialization}) has been confirmed on ${DateFormat('yyyy-MM-dd').format(widget.appointmentDate)} at ${widget.appointmentTime}.\nPayment method: Online\nPrice: EGY ${widget.price}\n\nThank you for using Tameny App.''',
    );

    setState(() => _isProcessing = false);

    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 50),
                const Text(
                  'Reservation Summary',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'GoiaDisplayVariable',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                _infoRow("Specialization", widget.specialization),
                _infoRow(
                  "Appointment",
                  widget.appointmentDate.toLocal().toString().split(" ")[0],
                ),
                _infoRow("Time", widget.appointmentTime),
                _infoRow("Total", "EGY {widget.price}"),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Name on card'),
                      _buildTextField(
                        _cardNumberController,
                        'Card number',
                        isNumber: true,
                      ),
                      _buildTextField(_expiryController, 'Expiry date (MM/YY)'),
                      _buildTextField(_cvvController, 'CVV', isNumber: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _isProcessing
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _completePayment,
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
                        'Complete payment',
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }
}


