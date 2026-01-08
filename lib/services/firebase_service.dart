import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Check if Firebase is available
  Future<bool> isFirebaseAvailable() async {
    try {
      // Simple connectivity check - try to access Firestore
      await FirebaseFirestore.instance.runTransaction((transaction) async {});
      return true;
    } catch (e) {
      print('Firebase not available: $e');
      return false;
    }
  }

  // Add product to Firebase
  Future<bool> addProduct(ProductModel product) async {
    try {
      final productData = product.toMap();
      productData['isSynced'] = 1;
      await productsCollection.doc(product.id).set(productData);
      return true;
    } catch (e) {
      print('Firebase addProduct error: $e');
      return false;
    }
  }

  // Get all products from Firebase
  Future<List<ProductModel>> getProducts() async {
    try {
      final QuerySnapshot snapshot = await productsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Firebase getProducts error: $e');
      return [];
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    final productData = product.toMap();
    productData['isSynced'] = 1;
    try {
      await productsCollection.doc(product.id).update(productData);
      return true;
    } catch (e) {
      print('Firebase updateProduct error: $e');
      // Try set if document doesn't exist
      try {
        await productsCollection.doc(product.id).set(productData);
        return true;
      } catch (e2) {
        print('Firebase set fallback error: $e2');
        return false;
      }
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      await productsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Firebase deleteProduct error: $e');
      return false;
    }
  }

  // Listen to real-time changes (Stream)
  Stream<List<ProductModel>> listenToProducts() {
    return productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ProductModel.fromMap(data);
          }).toList();
        });
  }
}
