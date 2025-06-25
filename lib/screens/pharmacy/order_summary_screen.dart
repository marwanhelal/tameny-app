import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/email_service.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String pharmacyId;
  final String pharmacyName;

  const OrderSummaryScreen({
    super.key,
    required this.pharmacyId,
    required this.pharmacyName,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String _paymentMethod = 'Cash on delivery';
  String _shippingAddress = '';
  bool _isPlacingOrder = false;

  final List<String> _paymentMethods = ['Cash on delivery', 'Pay online'];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: const Color(0xFF004B95),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('cart')
                .doc(uid)
                .collection('items')
                .where('pharmacyId', isEqualTo: widget.pharmacyId)
                .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;
          final total = items.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['price'] as num) * (item['quantity'] as num)).toDouble(),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pharmacy: ${widget.pharmacyName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...items.map(
                  (item) => ListTile(
                    leading: Image.network(item['imageUrl'], width: 40),
                    title: Text(item['name']),
                    subtitle: Text(
                      'Price: EGP ${item['price']} x ${item['quantity']}',
                    ),
                    trailing: Text(
                      'Subtotal: EGP ${(item['price'] * item['quantity'])}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total amount: EGP ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment method',
                  ),
                  items:
                      _paymentMethods
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => setState(() {
                        _paymentMethod = val!;
                      }),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Shipping address',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _shippingAddress = val,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isPlacingOrder
                            ? null
                            : () => _placeOrder(uid!, items, total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004B95),
                    ),
                    child:
                        _isPlacingOrder
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Place an order',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _placeOrder(
    String uid,
    List<QueryDocumentSnapshot> items,
    double total,
  ) async {
    setState(() {
      _isPlacingOrder = true;
    });

    final orderRef = FirebaseFirestore.instance.collection('orders').doc();

    await orderRef.set({
      'userId': uid,
      'pharmacyId': widget.pharmacyId,
      'pharmacyName': widget.pharmacyName,
      'total': total,
      'shippingAddress': _shippingAddress,
      'paymentMethod': _paymentMethod,
      'timestamp': FieldValue.serverTimestamp(),
      'items':
          items
              .map(
                (doc) => {
                  'productId': doc.id,
                  'name': doc['name'],
                  'price': doc['price'],
                  'quantity': doc['quantity'],
                  'imageUrl': doc['imageUrl'],
                },
              )
              .toList(),
    });

    await EmailService.sendEmail(
      toEmail: FirebaseAuth.instance.currentUser?.email ?? '',
      subject: 'Your Order is Confirmed!',
      content:
          'Your order from ${widget.pharmacyName} has been confirmed.\n\nTotal: EGP $total\nPayment: $_paymentMethod\nShipping Address: $_shippingAddress',
    );

    
    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(uid)
        .collection('items');
    final cartItems = await cartRef.get();
    for (var item in cartItems.docs) {
      await item.reference.delete();
    }

    setState(() {
      _isPlacingOrder = false;
    });

    Navigator.pushNamed(context, '/orderConfirmation');
  }
}


