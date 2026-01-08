import '../entities/ledger_entry.dart';
import '../repositories/customer_repository.dart';

class GetCustomerLedger {
  final CustomerRepository repository;

  GetCustomerLedger(this.repository);

  Future<List<LedgerEntry>> execute(String customerId) async {
    return await repository.getCustomerLedger(customerId);
  }
}
