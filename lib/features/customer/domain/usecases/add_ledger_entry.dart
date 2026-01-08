import '../entities/ledger_entry.dart';
import '../repositories/customer_repository.dart';

class AddLedgerEntry {
  final CustomerRepository repository;

  AddLedgerEntry(this.repository);

  Future<void> execute(LedgerEntry entry) async {
    await repository.addLedgerEntry(entry);
  }
}
