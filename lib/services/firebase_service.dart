import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Add product to Firebase
  Future<void> addProduct(ProductModel product) async {
    // Hum .set() use kar rahe hain taakay jo ID humne generate ki hai wahi document ID banay
    // Also ensuring isSynced is true on Firebase side
    final productData = product.toMap();
    productData['isSynced'] = true;

    await productsCollection.doc(product.id).set(productData);
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    await productsCollection.doc(product.id).update(product.toMap());
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }
}
