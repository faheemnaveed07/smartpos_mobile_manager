import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class SQLiteService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Database initialize
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'smartpos.db');
    return await openDatabase(
      path,
      version: 3, // Incremented version for sales table
      onCreate: (db, version) async {
        // Products table
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            name TEXT,
            sku TEXT,
            buyingPrice REAL,
            sellingPrice REAL,
            stock INTEGER,
            imagePath TEXT,
            category TEXT,
            createdAt TEXT,
            isSynced INTEGER
          )
        ''');

        // Customers table
        await db.execute('''
          CREATE TABLE customers(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            address TEXT,
            type TEXT DEFAULT 'REGULAR',
            outstandingBalance REAL DEFAULT 0,
            createdAt TEXT,
            isSynced INTEGER DEFAULT 0
          )
        ''');

        // Ledger entries table
        await db.execute('''
          CREATE TABLE ledger_entries(
            id TEXT PRIMARY KEY,
            customerId TEXT NOT NULL,
            date TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            description TEXT,
            isSynced INTEGER DEFAULT 0,
            FOREIGN KEY (customerId) REFERENCES customers(id) ON DELETE CASCADE
          )
        ''');

        // Sales table
        await db.execute('''
          CREATE TABLE sales(
            id TEXT PRIMARY KEY,
            saleDate TEXT NOT NULL,
            customerId TEXT,
            customerName TEXT,
            items TEXT NOT NULL,
            subtotal REAL NOT NULL,
            discount REAL DEFAULT 0,
            tax REAL DEFAULT 0,
            grandTotal REAL NOT NULL,
            paymentMethod TEXT DEFAULT 'CASH',
            amountPaid REAL,
            change REAL DEFAULT 0,
            profit REAL DEFAULT 0,
            isSynced INTEGER DEFAULT 0,
            createdAt TEXT,
            FOREIGN KEY (customerId) REFERENCES customers(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add customers table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS customers(
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              phone TEXT NOT NULL,
              email TEXT,
              address TEXT,
              type TEXT DEFAULT 'REGULAR',
              outstandingBalance REAL DEFAULT 0,
              createdAt TEXT,
              isSynced INTEGER DEFAULT 0
            )
          ''');

          // Add ledger entries table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ledger_entries(
              id TEXT PRIMARY KEY,
              customerId TEXT NOT NULL,
              date TEXT NOT NULL,
              amount REAL NOT NULL,
              type TEXT NOT NULL,
              description TEXT,
              isSynced INTEGER DEFAULT 0,
              FOREIGN KEY (customerId) REFERENCES customers(id) ON DELETE CASCADE
            )
          ''');
        }

        if (oldVersion < 3) {
          // Add sales table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS sales(
              id TEXT PRIMARY KEY,
              saleDate TEXT NOT NULL,
              customerId TEXT,
              customerName TEXT,
              items TEXT NOT NULL,
              subtotal REAL NOT NULL,
              discount REAL DEFAULT 0,
              tax REAL DEFAULT 0,
              grandTotal REAL NOT NULL,
              paymentMethod TEXT DEFAULT 'CASH',
              amountPaid REAL,
              change REAL DEFAULT 0,
              profit REAL DEFAULT 0,
              isSynced INTEGER DEFAULT 0,
              createdAt TEXT,
              FOREIGN KEY (customerId) REFERENCES customers(id)
            )
          ''');
        }
      },
    );
  }

  // Insert product
  Future<void> insertProduct(ProductModel product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Agar ID same ho to overwrite kare
    );
  }

  // Get all products
  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: "createdAt DESC",
    );
    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }

  // Get unsynced products (For Sync Logic)
  Future<List<ProductModel>> getUnsyncedProducts() async {
    final db = await database;
    // Sirf wo products layein jahan isSynced 0 hai
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  // Mark as synced
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'products',
      {'isSynced': 1}, // 1 means true in SQLite
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
