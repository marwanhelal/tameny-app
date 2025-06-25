import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/email_service.dart'; 
import '../dashboards/patient_dashboard_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final String connectionType;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;

  const PaymentScreen({
    super.key,
    required this.doctorData,
    required this.connectionType,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _submitPayment() async {
    if (_cardNameController.text.isEmpty ||
        _cardNumberController.text.length != 16 ||
        !_expiryDateController.text.contains('/') ||
        _cvvController.text.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid card information')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final patientEmail = widget.doctorData['email'];
      final doctorName = widget.doctorData['name'];
      final specialization = widget.doctorData['specialization'];
      final price = widget.doctorData['price'];
      final uid = user?.uid ?? '';

      final bookingRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add({
            'appointmentDate': widget.appointmentDate,
            'appointmentTime': widget.appointmentTime.format(context),
            'connectionType': widget.connectionType,
            'createdAt': FieldValue.serverTimestamp(),
            'doctorId': widget.doctorData['userId'],
            'doctorName': widget.doctorData['name'],
            'specialization': widget.doctorData['specialization'],
            'price': widget.doctorData['price'],
            'patientId': FirebaseAuth.instance.currentUser!.uid,
          });

      
      await EmailService.sendEmail(
        toEmail: patientEmail,
        subject: 'Doctor Appointment Confirmation',
        content:
            '''Your appointment with Dr. $doctorName ($specialization) has been confirmed on ${DateFormat('yyyy-MM-dd').format(widget.appointmentDate)} at ${widget.appointmentTime.format(context)}.\nConnection Type: ${widget.connectionType}\nPayment method: Credit Card\nPrice: EGY $price\n\nThank you for using Tameny App.''',
      );

      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handleSuccessfulPayment() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.doctorData['name'];
    final price = widget.doctorData['price'];
    final dateStr = widget.appointmentDate.toLocal().toString().split(' ')[0];
    final timeStr = widget.appointmentTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF004B95),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background image.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Text(
              "Booking Details",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),
            _buildSummaryTile("Doctor", doctorName),
            _buildSummaryTile("Date", dateStr),
            _buildSummaryTile("Time", timeStr),
            _buildSummaryTile("Connection", widget.connectionType),
            _buildSummaryTile("Total Price", "EGY $price"),
            const SizedBox(height: 20),
            const Text(
              "Enter Card Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField("Cardholder Name", _cardNameController),
            _buildTextField(
              "Card Number",
              _cardNumberController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField("Expiry Date (MM/YY)", _expiryDateController),
            _buildTextField(
              "CVV",
              _cvvController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isProcessing ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01B5A2),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        "Confirm Payment",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }
}


