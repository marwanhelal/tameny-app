import 'package:flutter/material.dart';
import 'package:tameny/screens/pharmacy/pharmacy_done_screen.dart';
import '../../../services/email_service.dart';

class PaymentFormScreen extends StatefulWidget {
  final double totalAmount;
  final String pharmacyName;
  final String userEmail;

  const PaymentFormScreen({
    super.key,
    required this.totalAmount,
    required this.pharmacyName,
    required this.userEmail,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  bool _isLoading = false;

  void _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    
    await Future.delayed(const Duration(seconds: 2));

    
    await EmailService.sendEmail(
      toEmail: widget.userEmail,
      subject: 'Your Pharmacy Order is Confirmed!',
      content: '''
Dear Customer,

✅ Your order from ${widget.pharmacyName} has been placed successfully.

💳 Payment Method: Pay Online
💰 Total: EGP ${widget.totalAmount.toStringAsFixed(2)}

Thank you for choosing Tameny App!

Stay healthy,  
Tameny Team
''',
    );

    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => PharmacyDoneScreen(
              userEmail: widget.userEmail,
              pharmacyName: widget.pharmacyName,
              totalPrice: widget.totalAmount,
              paymentMethod: 'Pay Online',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF004B95),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter Payment Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Cardholder Name'),
                validator:
                    (value) => value!.isEmpty ? 'Enter cardholder name' : null,
              ),
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.length < 16 ? 'Invalid card number' : null,
              ),
              TextFormField(
                controller: expiryController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                ),
                validator:
                    (value) => value!.isEmpty ? 'Enter expiry date' : null,
              ),
              TextFormField(
                controller: cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) => value!.length < 3 ? 'Invalid CVV' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01B5A2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Confirm Payment',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


