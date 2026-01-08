import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetSalesSummaryUseCase {
  final ReportsRepository repository;

  GetSalesSummaryUseCase(this.repository);

  Future<ReportData> execute({required String period}) async {
    return await repository.getSalesSummary(period: period);
  }
}
