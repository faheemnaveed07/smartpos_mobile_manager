import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sale_model.dart';

class SaleSQLiteService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Database initialize
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'smartpos_sales.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create sales table
        await db.execute('''
          CREATE TABLE sales(
            id TEXT PRIMARY KEY,
            items TEXT,
            subtotal REAL,
            tax REAL,
            discount REAL,
            grandTotal REAL,
            customerId TEXT,
            saleDate TEXT,
            paymentMethod TEXT,
            isSynced INTEGER
          )
        ''');
      },
    );
  }

  // Insert sale
  Future<void> insertSale(Sale sale) async {
    final db = await database;
    await db.insert(
      'sales',
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all sales
  Future<List<Sale>> getSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales',
      orderBy: "saleDate DESC",
    );
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  // Get unsynced sales
  Future<List<Sale>> getUnsyncedSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  // Mark sale as synced
  Future<void> markSaleAsSynced(String saleId) async {
    final db = await database;
    await db.update(
      'sales',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  // Get today's sales
  Future<List<Sale>> getTodaySales() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: 'saleDate >= ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: "saleDate DESC",
    );
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  // Get total sales amount for today
  Future<double> getTodayTotal() async {
    final sales = await getTodaySales();
    double total = 0;
    for (var sale in sales) {
      total += sale.grandTotal;
    }
    return total;
  }
}
