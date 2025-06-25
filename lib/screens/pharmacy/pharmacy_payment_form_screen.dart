import 'package:flutter/material.dart';
import 'pharmacy_order_confirmation_screen.dart';

class PharmacyPaymentFormScreen extends StatelessWidget {
  final String pharmacyName;
  final double totalAmount;

  const PharmacyPaymentFormScreen({
    super.key,
    required this.pharmacyName,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final cardNameController = TextEditingController();
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Order summary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pharmacy: $pharmacyName"),
            Text("Total amount: EGP ${totalAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 20),
            TextField(
              controller: cardNameController,
              decoration: const InputDecoration(labelText: "Name on card"),
            ),
            TextField(
              controller: cardNumberController,
              decoration: const InputDecoration(labelText: "Card number"),
            ),
            TextField(
              controller: expiryController,
              decoration: const InputDecoration(
                labelText: "Expiry date (MM/YY)",
              ),
            ),
            TextField(
              controller: cvvController,
              decoration: const InputDecoration(labelText: "CVV"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PharmacyOrderConfirmationScreen(
                          pharmacyName: pharmacyName,
                          totalAmount: totalAmount,
                        ),
                  ),
                );
              },
              child: const Text("Complete payment"),
            ),
          ],
        ),
      ),
    );
  }
}


