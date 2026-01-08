import 'dart:convert';
import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  double discount; // Per item discount

  CartItem({required this.product, this.quantity = 1, this.discount = 0});

  // Total price for this item
  double get totalPrice => (product.sellingPrice * quantity) - discount;

  // Copy with method
  CartItem copyWith({ProductModel? product, int? quantity, double? discount}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  // Convert to Map for SQLite/Firebase
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productSku': product.sku,
      'productPrice': product.sellingPrice,
      'quantity': quantity,
      'discount': discount,
      'totalPrice': totalPrice,
    };
  }

  // Create from Map (needs product reference)
  factory CartItem.fromMap(Map<String, dynamic> map, ProductModel product) {
    return CartItem(
      product: product,
      quantity: map['quantity'] ?? 1,
      discount: (map['discount'] ?? 0).toDouble(),
    );
  }

  // Convert to JSON string
  String toJson() => jsonEncode(toMap());
}
