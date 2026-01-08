import 'package:get/get.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/add_ledger_entry.dart';
import '../../domain/usecases/get_customer_ledger.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/datasources/customer_local_data_source.dart';
import '../controllers/customer_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut(() => CustomerLocalDataSource(Get.find()));

    // Repository
    Get.lazyPut<CustomerRepository>(() => CustomerRepositoryImpl(Get.find()));

    // UseCases
    Get.lazyPut(() => GetCustomers(Get.find()));
    Get.lazyPut(() => AddLedgerEntry(Get.find()));
    Get.lazyPut(() => GetCustomerLedger(Get.find()));

    // Controller (now takes 3 use cases)
    Get.lazyPut(() => CustomerController(Get.find(), Get.find(), Get.find()));
  }
}
