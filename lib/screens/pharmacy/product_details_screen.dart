import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String pharmacyId;
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productData,
    required this.pharmacyId,
    required this.productId,
  });

  Future<void> addToCart(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items');

    final existing =
        await cartRef.where('productId', isEqualTo: productId).limit(1).get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final newQty = (doc['quantity'] ?? 1) + 1;
      await cartRef.doc(doc.id).update({'quantity': newQty});
    } else {
      await cartRef.add({
        'productId': productId,
        'name': productData['name'],
        'price': productData['price'],
        'quantity': 1,
        'pharmacyId': pharmacyId,
        'imageUrl': productData['imageUrl'],
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final String name = productData['name'] ?? '';
    final String? imageUrl = productData['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(name.isNotEmpty ? name : 'Product Details'),
        backgroundColor: const Color(0xFF004B95),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
              )
            else
              Image.asset(
                'assets/products/${name.toLowerCase().replaceAll(' ', '_')}.png',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 100),
              ),

            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'EGP ${productData['price'].toString()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              productData['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => addToCart(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01B5A2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


