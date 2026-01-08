import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetCustomerLedgerUseCase {
  final ReportsRepository repository;

  GetCustomerLedgerUseCase(this.repository);

  Future<ReportData> execute() async {
    return await repository.getCustomerLedger();
  }
}
