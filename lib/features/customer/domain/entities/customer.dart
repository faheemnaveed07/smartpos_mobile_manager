class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String type; // "WALK_IN" or "REGULAR"
  final double outstandingBalance; // Udhaar
  final DateTime createdAt;
  final bool isSynced;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.type = 'REGULAR',
    this.outstandingBalance = 0.0,
    DateTime? createdAt,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // CopyWith for updates
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? type,
    double? outstandingBalance,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      type: type ?? this.type,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
