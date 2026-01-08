import '../../domain/entities/report_data.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_mock_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsMockDataSource mockDataSource;

  ReportsRepositoryImpl(this.mockDataSource);

  @override
  Future<ReportData> getSalesSummary({required String period}) async {
    // For now, return same data regardless of period
    // TODO: Filter by period
    return mockDataSource.getSalesSummaryToday();
  }

  @override
  Future<ReportData> getStockValue() async {
    return mockDataSource.getStockValue();
  }

  @override
  Future<ReportData> getCustomerLedger() async {
    return mockDataSource.getCustomerLedger();
  }

  @override
  Future<ReportData> getProfitLoss({required String period}) async {
    return mockDataSource.getProfitLoss();
  }

  @override
  Future<ReportData> getProductPerformance() async {
    return mockDataSource.getProductPerformance();
  }
}
