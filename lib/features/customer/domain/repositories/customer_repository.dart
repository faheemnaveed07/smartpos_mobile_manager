import '../entities/customer.dart';
import '../entities/ledger_entry.dart';

abstract class CustomerRepository {
  // Customer CRUD
  Future<List<Customer>> getCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);

  // Ledger operations
  Future<void> addLedgerEntry(LedgerEntry entry);
  Future<List<LedgerEntry>> getCustomerLedger(String customerId);

  // Calculate outstanding balance
  Future<double> calculateOutstandingBalance(String customerId);
}
