import '../entities/report_data.dart';

abstract class ReportsRepository {
  Future<ReportData> getSalesSummary({
    required String period,
  }); // period: 'today', 'week', 'month'
  Future<ReportData> getStockValue();
  Future<ReportData> getCustomerLedger();
  Future<ReportData> getProfitLoss({required String period});
  Future<ReportData> getProductPerformance();
}
