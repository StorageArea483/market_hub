import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add or update item in cart
  Future<bool> addToCart(int productId, int quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final cartRef = _firestore.collection('cart_items').doc(user.uid);
      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        // Cart exists, update it
        final data = cartDoc.data() as Map<String, dynamic>;
        List<dynamic> ids = data['ids'] ?? [];
        Map<String, dynamic> quantities = Map<String, dynamic>.from(
          data['quantities'] ?? {},
        );

        // Check if product already exists
        if (ids.contains(productId)) {
          // Update quantity
          quantities[productId.toString()] =
              (quantities[productId.toString()] ?? 0) + quantity;
        } else {
          // Add new product
          ids.add(productId);
          quantities[productId.toString()] = quantity;
        }

        await cartRef.update({'ids': ids, 'quantities': quantities});
      } else {
        // Create new cart
        await cartRef.set({
          'ids': [productId],
          'quantities': {productId.toString(): quantity},
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get cart items
  Future<Map<String, dynamic>?> getCartItems() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final cartDoc = await _firestore
          .collection('cart_items')
          .doc(user.uid)
          .get();
      if (cartDoc.exists) {
        return cartDoc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
