import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';

class SaleFirebaseService {
  final CollectionReference salesCollection = FirebaseFirestore.instance
      .collection('sales');

  // Add sale to Firestore
  Future<bool> addSale(Sale sale) async {
    try {
      await salesCollection.doc(sale.id).set(sale.toMap());
      return true;
    } catch (e) {
      print('Firebase addSale error: $e');
      return false;
    }
  }

  // Get all sales from Firestore
  Future<List<Sale>> getSales() async {
    try {
      QuerySnapshot snapshot = await salesCollection
          .orderBy('saleDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Firebase getSales error: $e');
      return [];
    }
  }

  // Real-time sales stream
  Stream<List<Sale>> listenToSales() {
    try {
      return salesCollection
          .orderBy('saleDate', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>))
                .toList(),
          );
    } catch (e) {
      print('Firebase listenToSales error: $e');
      return const Stream.empty();
    }
  }

  // Get today's sales from Firebase
  Future<List<Sale>> getTodaySales() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      QuerySnapshot snapshot = await salesCollection
          .where(
            'saleDate',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .orderBy('saleDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Firebase getTodaySales error: $e');
      return [];
    }
  }
}
