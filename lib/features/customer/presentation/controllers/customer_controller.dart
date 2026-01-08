import 'package:get/get.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/add_ledger_entry.dart';
import '../../domain/usecases/get_customer_ledger.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../../../core/services/sync_service.dart';

class CustomerController extends GetxController {
  final GetCustomers _getCustomers;
  final AddLedgerEntry _addLedgerEntry;
  final GetCustomerLedger _getCustomerLedger;
  final CustomerRepository _repository = Get.find();

  CustomerController(
    this._getCustomers,
    this._addLedgerEntry,
    this._getCustomerLedger,
  );

  // OBSERVABLES
  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<Customer> selectedCustomer = Rxn<Customer>();
  final RxList<LedgerEntry> customerLedger = <LedgerEntry>[].obs;
  final RxBool isLedgerLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      customers.value = await _getCustomers.execute();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new customer
  Future<void> addCustomer(Customer customer) async {
    try {
      await _repository.addCustomer(customer);
      Get.snackbar('Success', 'Customer added successfully');
      loadCustomers(); // Refresh list

      // Trigger background sync
      if (Get.isRegistered<SyncService>()) {
        SyncService.to.syncAll();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add customer: $e');
    }
  }

  // Add ledger entry (udhaar or payment)
  Future<void> addLedgerEntry({
    required String customerId,
    required double amount,
    required LedgerType type,
    required String description,
  }) async {
    final entry = LedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      date: DateTime.now(),
      amount: amount,
      type: type,
      description: description,
    );

    try {
      await _addLedgerEntry.execute(entry);
      Get.snackbar('Success', 'Entry added successfully');
      loadCustomers(); // Refresh list to update balances
      loadCustomerLedger(customerId); // Refresh ledger if open

      // Trigger background sync
      if (Get.isRegistered<SyncService>()) {
        SyncService.to.syncAll();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Quick udhaar entry
  Future<void> addUdhaar(String customerId, double amount) async {
    await addLedgerEntry(
      customerId: customerId,
      amount: amount,
      type: LedgerType.debit,
      description: 'Udhaar for purchase',
    );
  }

  Future<void> loadCustomerLedger(String customerId) async {
    isLedgerLoading.value = true;
    try {
      customerLedger.value = await _getCustomerLedger.execute(customerId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load ledger: $e');
    } finally {
      isLedgerLoading.value = false;
    }
  }

  // Payment received
  Future<void> addPayment(String customerId, double amount) async {
    await addLedgerEntry(
      customerId: customerId,
      amount: amount,
      type: LedgerType.credit,
      description: 'Payment received',
    );
  }
}
