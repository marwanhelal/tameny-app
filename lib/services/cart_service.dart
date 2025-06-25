import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Future<void> addToCart({
    required String pharmacyId,
    required String pharmacyName,
    required String productId,
    required String productName,
    required String productImage,
    required int price,
    int quantity = 1,
  }) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated.");
    }

    final docRef = _firestore
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(productId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      
      await docRef.update({'quantity': FieldValue.increment(quantity)});
    } else {
      
      await docRef.set({
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'price': price,
        'quantity': quantity,
        'pharmacyId': pharmacyId,
        'pharmacyName': pharmacyName,
      });
    }
  }

  
  Future<void> removeFromCart(String productId) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated.");
    }

    await _firestore
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  
  Future<void> clearCart() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated.");
    }

    final itemsSnapshot =
        await _firestore
            .collection('cart')
            .doc(userId)
            .collection('items')
            .get();

    for (var doc in itemsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  
  Stream<QuerySnapshot> getCartItemsStream() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated.");
    }

    return _firestore
        .collection('cart')
        .doc(userId)
        .collection('items')
        .snapshots();
  }

  
  Future<double> getTotalPrice() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated.");
    }

    final itemsSnapshot =
        await _firestore
            .collection('cart')
            .doc(userId)
            .collection('items')
            .get();

    double total = 0.0;
    for (var doc in itemsSnapshot.docs) {
      final data = doc.data();
      total += (data['price'] * data['quantity']);
    }
    return total;
  }
}


