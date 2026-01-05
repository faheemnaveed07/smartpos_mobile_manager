class Product {
  final String id;
  final String name;
  final String sku;  // Mobile IMEI/model number ke liye perfect
  final double buyingPrice;
  final double sellingPrice;
  final int stock;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;
  final bool isSynced; // Offline sync tracking

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
    this.imageUrl,
    required this.category,
    required this.createdAt,
    this.isSynced = false,
  });

  // SQLite ke liye Map conversion (line 25)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Map se Product object (line 41)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      sku: map['sku'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      stock: map['stock'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  // CopyWith method for updates (line 57)
  Product copyWith({/* TODO: Add all fields as optional parameters */}) {
    // TODO: Implement copyWith logic
    return this;
  }
}