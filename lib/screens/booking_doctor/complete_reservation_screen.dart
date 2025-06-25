import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/email_service.dart'; 
import 'reservation_summary_screen.dart'; 
import 'online_payment_screen.dart'; 


class CompleteReservationScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final int price;
  final String specialization;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;

  const CompleteReservationScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.price,
    required this.specialization,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  State<CompleteReservationScreen> createState() =>
      _CompleteReservationScreenState();
}

class _CompleteReservationScreenState extends State<CompleteReservationScreen> {
  String? _paymentMethod;
  bool _isLoading = false;

  Future<void> _completeReservation() async {
    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    if (_paymentMethod == "Online") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (_) => OnlinePaymentScreen(
                doctorName: widget.doctorName,
                specialization: widget.specialization,
                price: widget.price,
                appointmentDate: widget.appointmentDate,
                appointmentTime: widget.appointmentTime.format(context),
              ),
        ),
        (route) => false,
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    final patientId = user?.uid;
    final email = user?.email ?? "";

    final bookingData = {
      'doctorId': widget.doctorId,
      'doctorName': widget.doctorName,
      'patientId': patientId,
      'specialization': widget.specialization,
      'price': widget.price,
      'appointmentDate': widget.appointmentDate.toIso8601String(),
      'appointmentTime': widget.appointmentTime.format(context),
      'paymentMethod': _paymentMethod,
      'status': 'confirmed',
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('bookings').add(bookingData);

    
    await EmailService.sendEmail(
      toEmail: email,
      subject: 'Doctor Appointment Confirmation',
      content:
          '''Your appointment with Dr. ${widget.doctorName} (${widget.specialization}) has been confirmed on ${DateFormat('yyyy-MM-dd').format(widget.appointmentDate)} at ${widget.appointmentTime.format(context)}.\nPayment method: $_paymentMethod\nPrice: EGY ${widget.price}\n\nThank you for using Tameny App.''',
    );

    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ReservationSummaryScreen(
              doctorName: widget.doctorName,
              price: widget.price,
              specialization: widget.specialization,
              appointmentDate: widget.appointmentDate,
              appointmentTime: widget.appointmentTime.format(context),
              paymentMethod: _paymentMethod!,
            ),
      ),
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
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Complete your Reservation',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'GoiaDisplayVariable',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            _buildPaymentDropdown(),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _completeReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004B95),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Complete your reservation',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _paymentMethod,
          isExpanded: true,
          hint: const Text("Select payment method"),
          items:
              ['Online', 'Pay at clinic'].map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _paymentMethod = value;
            });
          },
        ),
      ),
    );
  }
}


