import 'package:flutter/material.dart';

class ReservationSummaryScreen extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final int price;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String paymentMethod;

  const ReservationSummaryScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.price,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.paymentMethod,
  });

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reservation Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'GoiaDisplayVariable',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _infoCard('Doctor', doctorName),
              _infoCard('Specialization', specialization),
              _infoCard(
                'Appointment Date',
                appointmentDate.toLocal().toString().split(' ')[0],
              ),
              _infoCard('Time', appointmentTime),
              _infoCard('Payment Method', paymentMethod),
              _infoCard(' Price', 'EGY $price'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed:
                    () => Navigator.popUntil(context, (route) => route.isFirst),
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
                  'Return to Dashboard',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}


