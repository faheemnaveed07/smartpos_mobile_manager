enum LedgerType { debit, credit } // debit = udhaar, credit = payment

class LedgerEntry {
  final String id;
  final String customerId;
  final DateTime date;
  final double amount;
  final LedgerType type;
  final String description; // e.g., "Mobile purchase", "Payment received"
  final bool isSynced;

  LedgerEntry({
    required this.id,
    required this.customerId,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    this.isSynced = false,
  });

  // Convenience getter
  String get typeLabel => type == LedgerType.debit ? 'Udhaar' : 'Payment';
}
