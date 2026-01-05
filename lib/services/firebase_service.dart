import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/androidenterprise/v1.dart';
import '../models/product_model.dart';

class FirebaseService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Add product to Firebase (line 7)
  Future<void> addProduct(Product product) async {
    // TODO: Convert to Map and set with product.id as doc ID
  }

  // Get all products (line 13)
  Future<List<Product>> getProducts() async {
    // TODO: Get docs, convert to Product list
    return [];
  }

  // Update product (line 19)
  Future<void> updateProduct(Product product) async {
    // TODO: Update doc
  }

  // Delete product (line 24)
  Future<void> deleteProduct(String id) async {
    // TODO: Delete doc
  }

  // Listen to real-time changes (line 29)
  Stream<List<Product>> listenToProducts() {
    // TODO: Return snapshot stream, map to Product list
    return const Stream.empty();
  }
}
