import '../entities/dashboard_stats.dart';

// Abstract repository - clean architecture
abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
  Stream<DashboardStats> watchDashboardStats(); // For live updates
}
