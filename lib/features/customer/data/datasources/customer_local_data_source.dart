import 'package:sqflite/sqflite.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/ledger_entry.dart';

class CustomerLocalDataSource {
  final Database database;

  CustomerLocalDataSource(this.database);

  // Get all customers with calculated balances
  Future<List<Customer>> getCustomers() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'customers',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Customer(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        phone: maps[i]['phone'] as String,
        email: maps[i]['email'] as String?,
        address: maps[i]['address'] as String?,
        type: maps[i]['type'] as String? ?? 'REGULAR',
        outstandingBalance:
            (maps[i]['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
        createdAt: maps[i]['createdAt'] != null
            ? DateTime.parse(maps[i]['createdAt'] as String)
            : DateTime.now(),
      );
    });
  }

  // Insert new customer
  Future<void> insertCustomer(Customer customer) async {
    await database.insert('customers', {
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'type': customer.type,
      'outstandingBalance': customer.outstandingBalance,
      'createdAt': customer.createdAt.toIso8601String(),
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert ledger entry and update customer balance
  Future<void> insertLedgerEntry(LedgerEntry entry) async {
    await database.transaction((txn) async {
      // Insert ledger entry
      await txn.insert('ledger_entries', {
        'id': entry.id,
        'customerId': entry.customerId,
        'date': entry.date.toIso8601String(),
        'amount': entry.amount,
        'type': entry.type == LedgerType.debit ? 'debit' : 'credit',
        'description': entry.description,
        'isSynced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Update customer's outstanding balance
      final balanceChange = entry.type == LedgerType.debit
          ? entry.amount
          : -entry.amount;

      await txn.rawUpdate(
        'UPDATE customers SET outstandingBalance = outstandingBalance + ? WHERE id = ?',
        [balanceChange, entry.customerId],
      );
    });
  }

  // Get ledger entries for a customer
  Future<List<LedgerEntry>> getCustomerLedger(String customerId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'ledger_entries',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return LedgerEntry(
        id: maps[i]['id'] as String,
        customerId: maps[i]['customerId'] as String,
        date: DateTime.parse(maps[i]['date'] as String),
        amount: (maps[i]['amount'] as num).toDouble(),
        type: maps[i]['type'] == 'debit' ? LedgerType.debit : LedgerType.credit,
        description: maps[i]['description'] as String,
      );
    });
  }

  // Calculate outstanding balance from ledger entries
  Future<double> calculateOutstandingBalance(String customerId) async {
    final result = await database.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) as balance
      FROM ledger_entries 
      WHERE customerId = ?
    ''',
      [customerId],
    );

    if (result.isNotEmpty) {
      return (result.first['balance'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    await database.update(
      'customers',
      {
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'type': customer.type,
        'isSynced': 0,
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  // Delete customer and their ledger entries
  Future<void> deleteCustomer(String customerId) async {
    await database.transaction((txn) async {
      // Delete ledger entries first
      await txn.delete(
        'ledger_entries',
        where: 'customerId = ?',
        whereArgs: [customerId],
      );
      // Delete customer
      await txn.delete('customers', where: 'id = ?', whereArgs: [customerId]);
    });
  }
}
