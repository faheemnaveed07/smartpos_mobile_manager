import 'package:get/get.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/usecases/get_sales_summary.dart';
import '../../domain/usecases/get_customer_ledger.dart';
import '../../domain/usecases/get_stock_value.dart';
import '../../../../core/services/pdf_service.dart';

class ReportsController extends GetxController {
  // USECASES (Injected via binding)
  final GetSalesSummaryUseCase _getSalesSummary;
  final GetCustomerLedgerUseCase _getCustomerLedger;
  final GetStockValueUseCase _getStockValue;

  ReportsController(
    this._getSalesSummary,
    this._getCustomerLedger,
    this._getStockValue,
  );

  // OBSERVABLES
  final RxInt currentTabIndex = 0.obs; // 0=Sales, 1=Stock, 2=Ledger
  final Rx<ReportData?> salesData = Rx<ReportData?>(null);
  final Rx<ReportData?> stockData = Rx<ReportData?>(null);
  final Rx<ReportData?> ledgerData = Rx<ReportData?>(null);
  final RxBool isLoading = false.obs;

  // Chart period filter
  final RxString salesPeriod = 'today'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllReports();
  }

  // Load reports based on active tab
  Future<void> loadAllReports() async {
    isLoading.value = true;
    try {
      // Load all reports in parallel
      await Future.wait([
        loadSalesReport(),
        loadStockReport(),
        loadLedgerReport(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSalesReport() async {
    salesData.value = await _getSalesSummary.execute(period: salesPeriod.value);
  }

  Future<void> loadStockReport() async {
    stockData.value = await _getStockValue.execute();
  }

  Future<void> loadLedgerReport() async {
    ledgerData.value = await _getCustomerLedger.execute();
  }

  // Change tab
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // Export current report to PDF
  Future<void> exportToPDF(ReportData? data) async {
    if (data == null) {
      Get.snackbar('Error', 'No data to export');
      return;
    }

    try {
      isLoading.value = true;

      // Prepare headers for PDF
      final headers = data.rawData.isNotEmpty
          ? data.rawData.first.keys
                .map((key) => {'key': key, 'label': key})
                .toList()
          : <Map<String, String>>[];

      // Prepare data rows
      final rows = data.rawData
          .map((row) => row.values.map((v) => v.toString()).toList())
          .toList();

      final file = await PdfService.generateReport(
        title: data.title,
        headers: headers,
        data: rows,
        fileName:
            '${data.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
      );

      Get.snackbar('Success', 'PDF generated successfully');

      // Share via WhatsApp
      await PdfService.shareViaWhatsApp(
        file,
        message: '${data.title}\n\nGenerated from SmartPOS Mobile Manager',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to export PDF: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
