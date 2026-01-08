import 'package:get/get.dart';
import '../../domain/usecases/get_sales_summary.dart';
import '../../domain/usecases/get_customer_ledger.dart';
import '../../domain/usecases/get_stock_value.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../data/datasources/reports_mock_datasource.dart';
import '../controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    // Mock data source
    Get.lazyPut(() => ReportsMockDataSource());

    // Repository
    Get.lazyPut<ReportsRepository>(() => ReportsRepositoryImpl(Get.find()));

    // UseCases
    Get.lazyPut(() => GetSalesSummaryUseCase(Get.find()));
    Get.lazyPut(() => GetCustomerLedgerUseCase(Get.find()));
    Get.lazyPut(() => GetStockValueUseCase(Get.find()));

    // Controller
    Get.lazyPut(() => ReportsController(Get.find(), Get.find(), Get.find()));
  }
}
