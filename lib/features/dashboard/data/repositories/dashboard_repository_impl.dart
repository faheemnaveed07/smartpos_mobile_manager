import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_stats_model.dart';

// Repository implementation - SOLID: D (Dependency Inversion)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource local;
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl({required this.local, required this.remote});

  @override
  Future<DashboardStats> getDashboardStats() async {
    // OFFLINE-FIRST: Try local first
    try {
      final sales = await local.getTodaySales();
      final profit = await local.getTodayProfit();
      final receivable = await local.getTotalReceivable();
      final lowStock = await local.getLowStockCount();
      final hourly = await local.getHourlySales();
      final pendingSync = await local.getPendingSyncCount();

      return DashboardStatsModel.fromData(
        sales: sales,
        profit: profit,
        receivable: receivable,
        lowStock: lowStock,
        hourly: hourly,
        pendingSync: pendingSync,
      );
    } catch (e) {
      // If local fails, try remote
      // TODO: Implement remote fallback
      rethrow;
    }
  }

  @override
  Stream<DashboardStats> watchDashboardStats() {
    // TODO: Return stream that combines local and remote updates
    return const Stream.empty();
  }
}
