// Pure entity, no dependencies
class DashboardStats {
  final double todaySales;
  final double todayProfit;
  final double totalReceivable; // Udhaar/Khata
  final int lowStockCount;
  final List<HourlyData> hourlySales;
  final int pendingSyncCount;

  DashboardStats({
    required this.todaySales,
    required this.todayProfit,
    required this.totalReceivable,
    required this.lowStockCount,
    required this.hourlySales,
    required this.pendingSyncCount,
  });
}

// For chart
class HourlyData {
  final int hour; // 0-23
  final double sales;

  HourlyData({required this.hour, required this.sales});
}
