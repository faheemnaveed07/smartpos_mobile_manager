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
      version: 4, // Increment to force migration
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

    // User Profile table for Local Auth
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        shopName TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
    if (oldVersion < 2) {
      // Add updatedAt column to products if not exists
      try {
        await db.execute('ALTER TABLE products ADD COLUMN updatedAt TEXT');
      } catch (e) {
        // Column may already exist
      }
    }
    if (oldVersion < 3) {
      // Add user_profile table for local auth
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_profile (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          phone TEXT,
          shopName TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      // Ensure updatedAt column exists (for older databases)
      try {
        await db.execute('ALTER TABLE products ADD COLUMN updatedAt TEXT');
      } catch (e) {
        // Column already exists, ignore
      }
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

  // ==================== LOCAL AUTH (user_profile) ====================

  /// Ensure user_profile table exists (fallback for old databases)
  Future<void> _ensureUserProfileTable() async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        shopName TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Register a new local user
  Future<Map<String, dynamic>?> registerUserLocal({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? shopName,
  }) async {
    final db = await instance.database;

    // Ensure table exists first
    await _ensureUserProfileTable();

    // Check if email already exists
    final existing = await db.query(
      'user_profile',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (existing.isNotEmpty) {
      return null; // User already exists
    }

    final user = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email.toLowerCase(),
      'password': password,
      'phone': phone ?? '',
      'shopName': shopName ?? 'My Shop',
      'createdAt': DateTime.now().toIso8601String(),
    };

    await db.insert('user_profile', user);
    return user;
  }

  /// Login with email and password
  Future<Map<String, dynamic>?> loginUserLocal({
    required String email,
    required String password,
  }) async {
    final db = await instance.database;

    // Ensure table exists first
    await _ensureUserProfileTable();

    final result = await db.query(
      'user_profile',
      where: 'email = ? AND password = ?',
      whereArgs: [email.toLowerCase(), password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null; // Invalid credentials
  }

  /// Get current user by ID
  Future<Map<String, dynamic>?> getCurrentUserLocal(String id) async {
    final db = await instance.database;

    // Ensure table exists first
    await _ensureUserProfileTable();

    final result = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;

    final result = await db.query(
      'user_profile',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
