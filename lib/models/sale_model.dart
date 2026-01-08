import 'dart:convert';
import 'cart_item_model.dart';

class Sale {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double grandTotal;
  final String customerId; // "WALK_IN" for walk-in customers
  final DateTime saleDate;
  final bool isSynced;
  final String paymentMethod; // Cash, Card, UPI

  Sale({
    required this.id,
    required this.items,
    required this.subtotal,
    this.tax = 0,
    this.discount = 0,
    required this.grandTotal,
    required this.customerId,
    required this.saleDate,
    this.isSynced = false,
    this.paymentMethod = 'Cash',
  });

  // Calculate totals from cart items
  factory Sale.fromCartItems({
    required String id,
    required List<CartItem> cartItems,
    required String customerId,
    String paymentMethod = 'Cash',
    double taxPercentage = 10, // 10% tax
    double extraDiscount = 0,
  }) {
    // Calculate subtotal = sum of all cartItem.totalPrice
    double subtotal = cartItems.fold(0, (sum, item) => sum + item.totalPrice);

    // Calculate tax
    double tax = subtotal * taxPercentage / 100;

    // Calculate grandTotal
    double grandTotal = subtotal + tax - extraDiscount;

    return Sale(
      id: id,
      items: cartItems,
      subtotal: subtotal,
      tax: tax,
      discount: extraDiscount,
      grandTotal: grandTotal,
      customerId: customerId,
      saleDate: DateTime.now(),
      paymentMethod: paymentMethod,
    );
  }

  // SQLite Map conversion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'grandTotal': grandTotal,
      'customerId': customerId,
      'saleDate': saleDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Create from Map (for SQLite)
  factory Sale.fromMap(Map<String, dynamic> map) {
    // Items ko decode karna - simplified version (items list nahi restore karenge)
    return Sale(
      id: map['id'] ?? '',
      items: [], // Items ko restore karna complex hai, abhi empty rakhte hain
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      grandTotal: (map['grandTotal'] ?? 0).toDouble(),
      customerId: map['customerId'] ?? 'WALK_IN',
      saleDate: DateTime.tryParse(map['saleDate'] ?? '') ?? DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      isSynced: map['isSynced'] == 1,
    );
  }

  // Copy with method
  Sale copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? grandTotal,
    String? customerId,
    DateTime? saleDate,
    bool? isSynced,
    String? paymentMethod,
  }) {
    return Sale(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      customerId: customerId ?? this.customerId,
      saleDate: saleDate ?? this.saleDate,
      isSynced: isSynced ?? this.isSynced,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
