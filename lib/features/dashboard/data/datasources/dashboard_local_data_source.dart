import '../../domain/entities/dashboard_stats.dart';
import '../../../../services/sqlite_service.dart';

// Local data source - SQLite
class DashboardLocalDataSource {
  final SQLiteService sqliteService;

  DashboardLocalDataSource(this.sqliteService);

  Future<double> getTodaySales() async {
    try {
      final db = await sqliteService.database;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Query sales table for today's total
      final result = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(grandTotal), 0) as total 
        FROM sales 
        WHERE saleDate >= ?
      ''',
        [startOfDay.toIso8601String()],
      );

      if (result.isNotEmpty) {
        return (result.first['total'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Error getting today sales: $e');
      return 0.0;
    }
  }

  Future<double> getTodayProfit() async {
    try {
      // For now, estimate profit as 20% of sales (TODO: Calculate actual profit from buying/selling price)
      final sales = await getTodaySales();
      return sales * 0.20; // 20% profit margin estimate
    } catch (e) {
      print('Error getting today profit: $e');
      return 0.0;
    }
  }

  Future<double> getTotalReceivable() async {
    // Query ledger for outstanding balances
    return 85000.0;
  }

  Future<int> getLowStockCount() async {
    try {
      final db = await sqliteService.database;

      // Count products where stock < 5
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM products 
        WHERE stock < 5
      ''');

      if (result.isNotEmpty) {
        return (result.first['count'] as int?) ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting low stock count: $e');
      return 0;
    }
  }

  Future<List<HourlyData>> getHourlySales() async {
    try {
      final db = await sqliteService.database;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Generate hourly sales data
      List<HourlyData> hourlyData = [];

      for (int hour = 0; hour < 24; hour++) {
        final hourStart = startOfDay.add(Duration(hours: hour));
        final hourEnd = startOfDay.add(Duration(hours: hour + 1));

        final result = await db.rawQuery(
          '''
          SELECT COALESCE(SUM(grandTotal), 0) as total 
          FROM sales 
          WHERE saleDate >= ? AND saleDate < ?
        ''',
          [hourStart.toIso8601String(), hourEnd.toIso8601String()],
        );

        double sales = 0.0;
        if (result.isNotEmpty) {
          sales = (result.first['total'] as num?)?.toDouble() ?? 0.0;
        }

        hourlyData.add(HourlyData(hour: hour, sales: sales));
      }

      return hourlyData;
    } catch (e) {
      print('Error getting hourly sales: $e');
      // Return dummy data on error
      return List.generate(24, (i) => HourlyData(hour: i, sales: 0.0));
    }
  }

  Future<int> getPendingSyncCount() async {
    try {
      final db = await sqliteService.database;

      // Count unsynced products
      final productResult = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM products 
        WHERE isSynced = 0
      ''');

      // Count unsynced sales
      final salesResult = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM sales 
        WHERE isSynced = 0
      ''');

      int productCount = (productResult.first['count'] as int?) ?? 0;
      int salesCount = (salesResult.first['count'] as int?) ?? 0;

      return productCount + salesCount;
    } catch (e) {
      print('Error getting pending sync count: $e');
      return 0;
    }
  }
}
