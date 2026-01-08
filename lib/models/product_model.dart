class ProductModel {
  final String id;
  final String name;
  final String sku; // IMEI / Model No
  final double buyingPrice;
  final double sellingPrice;
  final int stock;
  final String? imagePath; // Renamed from imageUrl to imagePath
  final String category;
  final DateTime createdAt;
  final bool isSynced; // Offline sync tracking

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
    this.imagePath,
    required this.category,
    required this.createdAt,
    this.isSynced = false,
  });

  // SQLite ke liye Map conversion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'imagePath':
          imagePath, // Database column name should effectively be imagePath
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Map se Product object (with Safety Checks)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      // Safe parsing: Agar int aye to double mein convert kare
      buyingPrice: (map['buyingPrice'] is int)
          ? (map['buyingPrice'] as int).toDouble()
          : (map['buyingPrice'] ?? 0.0),
      sellingPrice: (map['sellingPrice'] is int)
          ? (map['sellingPrice'] as int).toDouble()
          : (map['sellingPrice'] ?? 0.0),
      stock: map['stock'] ?? 0,
      imagePath: map['imagePath'],
      category: map['category'] ?? 'General',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      isSynced: map['isSynced'] == 1,
    );
  }

  // CopyWith method (Fully Implemented)
  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    double? buyingPrice,
    double? sellingPrice,
    int? stock,
    String? imagePath,
    String? category,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
