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
      version: 1,
      onCreate: (db, version) async {
        // Table create kar rahe hain jo ProductModel se match kare
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
