import '../../domain/entities/customer.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource local;

  CustomerRepositoryImpl(this.local);

  @override
  Future<List<Customer>> getCustomers() async {
    return await local.getCustomers();
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await local.insertCustomer(customer);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await local.updateCustomer(customer);
  }

  @override
  Future<void> addLedgerEntry(LedgerEntry entry) async {
    await local.insertLedgerEntry(entry);
  }

  @override
  Future<List<LedgerEntry>> getCustomerLedger(String customerId) async {
    return await local.getCustomerLedger(customerId);
  }

  @override
  Future<double> calculateOutstandingBalance(String customerId) async {
    return await local.calculateOutstandingBalance(customerId);
  }
}
