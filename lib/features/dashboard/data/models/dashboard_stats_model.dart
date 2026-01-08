import '../../domain/entities/dashboard_stats.dart';

// DTO - Extends entity
class DashboardStatsModel extends DashboardStats {
  DashboardStatsModel({
    required super.todaySales,
    required super.todayProfit,
    required super.totalReceivable,
    required super.lowStockCount,
    required super.hourlySales,
    required super.pendingSyncCount,
  });

  // Factory from SQLite/Firebase data
  factory DashboardStatsModel.fromData({
    required double sales,
    required double profit,
    required double receivable,
    required int lowStock,
    required List<HourlyData> hourly,
    required int pendingSync,
  }) {
    return DashboardStatsModel(
      todaySales: sales,
      todayProfit: profit,
      totalReceivable: receivable,
      lowStockCount: lowStock,
      hourlySales: hourly,
      pendingSyncCount: pendingSync,
    );
  }
}
