import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartpos.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // Increment when adding tables
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create all tables
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT NOT NULL,
        buyingPrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        stock INTEGER NOT NULL,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        discount REAL NOT NULL,
        grandTotal REAL NOT NULL,
        saleDate TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        type TEXT NOT NULL,
        outstandingBalance REAL DEFAULT 0,
        createdAt TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ledger_entries (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL, -- 'debit' or 'credit'
        description TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
    if (oldVersion < 2) {
      // Add updatedAt column to products
      await db.execute('ALTER TABLE products ADD COLUMN updatedAt TEXT');
    }
  }

  // CRUD: Products
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }

  Future<void> insertProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    await db.insert(
      'products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedProducts() async {
    final db = await instance.database;
    return await db.query('products', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<void> markProductAsSynced(String id) async {
    final db = await instance.database;
    await db.update(
      'products',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD: Sales (similar pattern)
  Future<List<Map<String, dynamic>>> getUnsyncedSales() async {
    final db = await instance.database;
    return await db.query('sales', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<void> markSaleAsSynced(String id) async {
    final db = await instance.database;
    await db.update('sales', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // Get database file path for backup
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'smartpos.db');
  }

  // Export entire DB as bytes
  Future<List<int>> exportDatabase() async {
    final path = await getDatabasePath();
    return await File(path).readAsBytes();
  }

  // Import DB from bytes (restore)
  Future<void> importDatabase(List<int> bytes) async {
    final path = await getDatabasePath();
    // Close existing connection before overwriting
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await File(path).writeAsBytes(bytes);
  }

  // ==================== PRODUCT CRUD ====================
  Future<void> updateProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    await db.update(
      'products',
      {...product, 'isSynced': 0}, // Mark as unsynced after update
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== SALES CRUD ====================
  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await instance.database;
    return await db.query('sales', orderBy: 'saleDate DESC');
  }

  Future<void> insertSale(Map<String, dynamic> sale) async {
    final db = await instance.database;
    await db.insert(
      'sales',
      sale,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== CUSTOMER CRUD ====================
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await instance.database;
    return await db.query('customers');
  }

  Future<void> insertCustomer(Map<String, dynamic> customer) async {
    final db = await instance.database;
    await db.insert(
      'customers',
      customer,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCustomer(Map<String, dynamic> customer) async {
    final db = await instance.database;
    await db.update(
      'customers',
      {...customer, 'isSynced': 0},
      where: 'id = ?',
      whereArgs: [customer['id']],
    );
  }

  Future<void> deleteCustomer(String id) async {
    final db = await instance.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedCustomers() async {
    final db = await instance.database;
    return await db.query('customers', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<void> markCustomerAsSynced(String id) async {
    final db = await instance.database;
    await db.update(
      'customers',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== LEDGER CRUD ====================
  Future<List<Map<String, dynamic>>> getLedgerEntriesForCustomer(
    String customerId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'ledger_entries',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
  }

  Future<void> insertLedgerEntry(Map<String, dynamic> entry) async {
    final db = await instance.database;
    await db.insert(
      'ledger_entries',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLedgerEntries() async {
    final db = await instance.database;
    return await db.query(
      'ledger_entries',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markLedgerEntryAsSynced(String id) async {
    final db = await instance.database;
    await db.update(
      'ledger_entries',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== SYNC UTILITIES ====================
  Future<int> getTotalUnsyncedCount() async {
    final products = await getUnsyncedProducts();
    final sales = await getUnsyncedSales();
    final customers = await getUnsyncedCustomers();
    final ledger = await getUnsyncedLedgerEntries();
    return products.length + sales.length + customers.length + ledger.length;
  }
}
