import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  void _showEditDialog(DocumentSnapshot order) async {
    final items = List<Map<String, dynamic>>.from(order['items']);
    final updatedItems = [...items];
    final controllerMap = <int, TextEditingController>{};

    for (var i = 0; i < items.length; i++) {
      controllerMap[i] = TextEditingController(
        text: items[i]['quantity'].toString(),
      );
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Order Quantities'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item['name'])),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: controllerMap[index],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Qty'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  double newTotal = 0;
                  for (var i = 0; i < updatedItems.length; i++) {
                    final qty = int.tryParse(controllerMap[i]!.text) ?? 1;
                    updatedItems[i]['quantity'] = qty;
                    newTotal += qty * updatedItems[i]['price'];
                  }

                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.id)
                      .update({'items': updatedItems, 'total': newTotal});

                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showCancelDialog(DocumentSnapshot order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Cancel Order?"),
            content: const Text("Are you sure you want to cancel this order?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.id)
                      .update({'status': 'Cancelled'});
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Yes, Cancel"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFF004B95),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = List<Map<String, dynamic>>.from(order['items']);
              final createdAt = (order['createdAt'] as Timestamp).toDate();
              final status = order['status'];
              final total = order['total'];

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                child: ExpansionTile(
                  title: Text("Order #${order.id.substring(0, 6)}"),
                  subtitle: Text("${createdAt.toLocal()} — Status: $status"),
                  children: [
                    ...items.map(
                      (item) => ListTile(
                        title: Text(item['name']),
                        subtitle: Text("Qty: ${item['quantity']}"),
                        trailing: Text(
                          "EGP ${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Total: EGP ${total.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (status != 'Cancelled')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showEditDialog(order),
                            child: const Text("Edit"),
                          ),
                          TextButton(
                            onPressed: () => _showCancelDialog(order),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


