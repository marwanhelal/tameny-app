import 'package:flutter/material.dart';
import '../../services/email_service.dart';
import 'pharmacy_order_done_screen.dart';

class PharmacyOrderConfirmationScreen extends StatefulWidget {
  final String pharmacyName;
  final double totalAmount;

  const PharmacyOrderConfirmationScreen({
    super.key,
    required this.pharmacyName,
    required this.totalAmount,
  });

  @override
  State<PharmacyOrderConfirmationScreen> createState() =>
      _PharmacyOrderConfirmationScreenState();
}

class _PharmacyOrderConfirmationScreenState
    extends State<PharmacyOrderConfirmationScreen> {
  final emailController = TextEditingController();
  bool isSending = false;

  Future<void> sendEmail() async {
    setState(() => isSending = true);

    await EmailService.sendEmail(
      toEmail: emailController.text,
      subject: "Pharmacy Order Confirmation",
      content: '''
Your order from ${widget.pharmacyName} is confirmed.

🛒 Total: EGP ${widget.totalAmount.toStringAsFixed(2)}
💳 Payment method: Online

Thank you for using the Tameny App.
''',
    );

    setState(() => isSending = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PharmacyOrderDoneScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order confirmed!")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Pharmacy: ${widget.pharmacyName}"),
            Text("Total amount: EGP ${widget.totalAmount}"),
            Text("Payment: Online"),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Enter your email for confirmation",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSending ? null : sendEmail,
              child: const Text("Send confirmation"),
            ),
          ],
        ),
      ),
    );
  }
}


