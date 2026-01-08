import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

// UseCase - SINGLE RESPONSIBILITY (SOLID: S)
class GetDashboardStats {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  // Execute method - can be called from controller
  Future<DashboardStats> execute() async {
    return await repository.getDashboardStats();
  }

  // Stream for live updates
  Stream<DashboardStats> watch() {
    return repository.watchDashboardStats();
  }
}
