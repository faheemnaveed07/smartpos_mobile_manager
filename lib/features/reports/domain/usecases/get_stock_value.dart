import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetStockValueUseCase {
  final ReportsRepository repository;

  GetStockValueUseCase(this.repository);

  Future<ReportData> execute() async {
    return await repository.getStockValue();
  }
}
