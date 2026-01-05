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

  // Database initialize (line 13)
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'smartpos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // TODO: Create products table
        // HINT: Use db.execute('CREATE TABLE products (...)')
        // Columns: id (TEXT PRIMARY KEY), name, sku, buyingPrice, sellingPrice, stock, imageUrl, category, createdAt, isSynced
      },
    );
  }

  // Insert product (line 26)
  Future<void> insertProduct(Product product) async {
    final db = await database;
    // TODO: Insert logic with conflictAlgorithm: ConflictAlgorithm.replace
  }

  // Get all products (line 32)
  Future<List<Product>> getProducts() async {
    final db = await database;
    // TODO: Query all products, return List<Product>
    return [];
  }

  // Update product (line 39)
  Future<void> updateProduct(Product product) async {
    // TODO: Update logic
  }

  // Delete product (line 44)
  Future<void> deleteProduct(String id) async {
    // TODO: Delete logic
  }

  // Get unsynced products (line 49)
  Future<List<Product>> getUnsyncedProducts() async {
    // TODO: Query where isSynced = 0
    return [];
  }

  // Mark as synced (line 55)
  Future<void> markAsSynced(String id) async {
    // TODO: Update isSynced = 1
  }
}
