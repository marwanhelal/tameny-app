import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_screen.dart';

class PharmacyProfileScreen extends StatelessWidget {
  final String pharmacyId;
  final Map<String, dynamic> pharmacyData;

  const PharmacyProfileScreen({
    super.key,
    required this.pharmacyId,
    required this.pharmacyData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pharmacyData['name'] ?? 'Pharmacy'),
        backgroundColor: const Color(0xFF004B95),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cartScreen');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                child: ListTile(
                  leading: Image.asset(
                    pharmacyData['logo'],
                    width: 50,
                    height: 50,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.local_pharmacy, size: 40),
                  ),
                  title: Text(pharmacyData['name'] ?? ''),
                  subtitle: Text(pharmacyData['address'] ?? ''),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Products Available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('pharmacies')
                        .doc(pharmacyId)
                        .collection('products')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final productDoc = products[index];
                      final product = productDoc.data() as Map<String, dynamic>;
                      final quantityController = TextEditingController(
                        text: '1',
                      );

                      return Card(
                        color: Colors.white.withOpacity(0.95),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailsScreen(
                                        productData: product,
                                        pharmacyId: pharmacyId,
                                        productId: productDoc.id,
                                      ),
                                ),
                              );
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/products/${(product['name'] as String).toLowerCase().replaceAll(' ', '_')}.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          const Icon(Icons.medication_outlined),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? 'Unnamed',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Price: EGP ${product['price'] ?? 0}',
                                      ),
                                      Text('Stock: ${product['stock'] ?? 0}'),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            height: 30,
                                            child: TextField(
                                              controller: quantityController,
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final userId =
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      ?.uid;
                                              if (userId == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "You must be logged in to add items.",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              final quantity =
                                                  int.tryParse(
                                                    quantityController.text,
                                                  ) ??
                                                  1;

                                              final cartItem = {
                                                'pharmacyId': pharmacyId,
                                                'productId': productDoc.id,
                                                'name': product['name'],
                                                'price': product['price'],
                                                'quantity': quantity,
                                                'stock': product['stock'],
                                              };

                                              final cartRef = FirebaseFirestore
                                                  .instance
                                                  .collection('cart')
                                                  .doc(userId)
                                                  .collection('items');

                                              final existingItem =
                                                  await cartRef
                                                      .where(
                                                        'productId',
                                                        isEqualTo:
                                                            productDoc.id,
                                                      )
                                                      .limit(1)
                                                      .get();

                                              if (existingItem
                                                  .docs
                                                  .isNotEmpty) {
                                                final existingDoc =
                                                    existingItem.docs.first;
                                                await existingDoc.reference.update({
                                                  'quantity':
                                                      (existingDoc
                                                              .data()['quantity'] ??
                                                          1) +
                                                      quantity,
                                                });
                                              } else {
                                                await cartRef.add(cartItem);
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product['name']} added to cart',
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF004B95,
                                              ),
                                            ),
                                            child: const Text('Add to cart'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


