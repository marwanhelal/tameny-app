import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/email_service.dart';
import 'payment_form_screen.dart';

class PharmacyOrderSummaryScreen extends StatefulWidget {
  final String pharmacyId;

  const PharmacyOrderSummaryScreen({super.key, required this.pharmacyId});

  @override
  State<PharmacyOrderSummaryScreen> createState() =>
      _PharmacyOrderSummaryScreenState();
}

class _PharmacyOrderSummaryScreenState
    extends State<PharmacyOrderSummaryScreen> {
  String selectedPayment = 'Cash on delivery';
  bool isPlacingOrder = false;

  Future<void> placeOrder() async {
    if (selectedPayment == "Pay online") {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final cartRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('items');

      final cartSnapshot = await cartRef.get();
      final items = cartSnapshot.docs;

      if (items.isEmpty) return;

      double total = 0;
      for (var item in items) {
        final data = item.data();
        total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
      }

      final pharmacyDoc =
          await FirebaseFirestore.instance
              .collection('pharmacies')
              .doc(widget.pharmacyId)
              .get();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaymentFormScreen(
                totalAmount: total,
                pharmacyName: pharmacyDoc.data()?['name'] ?? 'Pharmacy',
                userEmail: user.email ?? '',
              ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isPlacingOrder = true);

    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('items');

    final cartSnapshot = await cartRef.get();
    final items = cartSnapshot.docs;

    if (items.isEmpty) return;

    double total = 0;
    List<Map<String, dynamic>> products = [];

    for (var item in items) {
      final data = item.data();
      total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
      products.add({
        'productId': item.id,
        'name': data['name'],
        'price': data['price'],
        'quantity': data['quantity'],
      });
    }

    await FirebaseFirestore.instance.collection('pharmacy_orders').add({
      'userId': user.uid,
      'pharmacyId': widget.pharmacyId,
      'products': products,
      'totalPrice': total,
      'paymentMethod': selectedPayment,
      'orderTime': Timestamp.now(),
    });

    await EmailService.sendEmail(
      toEmail: user.email ?? '',
      subject: 'Your Pharmacy Order is Confirmed!',
      content: '''
Dear Customer,

Your order has been successfully placed at our pharmacy.

📦 Total Items: ${products.length}
💰 Total Price: EGP $total.toStringAsFixed(2)
💳 Payment Method: $selectedPayment

Thank you for choosing Tameny App!
''',
    );

    for (var item in items) {
      await cartRef.doc(item.id).delete();
    }

    setState(() => isPlacingOrder = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Order placed successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: const Color(0xFF004B95),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedPayment,
              items: const [
                DropdownMenuItem(
                  value: 'Cash on delivery',
                  child: Text('Cash on delivery'),
                ),
                DropdownMenuItem(
                  value: 'Pay online',
                  child: Text('Pay online'),
                ),
              ],
              onChanged:
                  (value) => setState(
                    () => selectedPayment = value ?? 'Cash on delivery',
                  ),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            isPlacingOrder
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01B5A2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}


