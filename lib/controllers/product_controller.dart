import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/sqlite_service.dart';
import '../services/firebase_service.dart';

class ProductController extends GetxController {
  // Services (line 6)
  final SQLiteService _sqliteService = Get.put(SQLiteService());
  final FirebaseService _firebaseService = Get.put(FirebaseService());

  // Observables (line 10)
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    // TODO: Listen to Firebase changes and auto-sync
  }

  // Load products from local DB (line 21)
  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      // TODO: Load from SQLite, store in products list
      // HINT: products.value = await _sqliteService.getProducts();
    } finally {
      isLoading.value = false;
    }
  }

  // Add product (offline-first) (line 31)
  Future<void> addProduct(Product product) async {
    try {
      // 1. Save to SQLite (line 34)
      await _sqliteService.insertProduct(product);

      // 2. Try to sync to Firebase (line 37)
      if (await Get.find<AuthController>().isOnline()) {
        await _firebaseService.addProduct(product);
        await _sqliteService.markAsSynced(product.id);
      }

      // 3. Reload local list (line 43)
      await loadProducts();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Sync all unsynced products (line 50)
  Future<void> syncProducts() async {
    isSyncing.value = true;
    try {
      // TODO: Get unsynced products, upload to Firebase, mark as synced
      Get.snackbar('Success', 'Products synced');
    } catch (e) {
      Get.snackbar('Sync Error', e.toString());
    } finally {
      isSyncing.value = false;
    }
  }
}
