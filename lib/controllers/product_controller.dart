import 'package:get/get.dart';
// Note: Ensure AuthController is created and put in main.dart or app_pages.dart
// import 'package:smartpos_mobile_manager/controllers/auth_controller.dart';
import '../models/product_model.dart';
import '../services/sqlite_service.dart';
import '../services/firebase_service.dart';

class ProductController extends GetxController {
  // Services
  final SQLiteService _sqliteService = Get.put(SQLiteService());
  final FirebaseService _firebaseService = Get.put(FirebaseService());

  // Observables
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // Load products from local DB (Offline First Approach)
  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final localData = await _sqliteService.getProducts();
      products.assignAll(localData);
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add product (Save Local -> Try Sync -> Update UI)
  Future<void> addProduct(ProductModel product) async {
    try {
      // 1. Save to SQLite immediately
      await _sqliteService.insertProduct(product);

      // Update UI immediately (Optimistic UI)
      products.insert(0, product);

      // 2. Try to sync to Firebase if Online
      // Note: Make sure AuthController is accessible via Get.find()
      // bool isOnline = Get.find<AuthController>().isOnline();
      bool isOnline =
          true; // Temporary hardcoded check for testing logic. Replace with AuthController logic.

      if (isOnline) {
        await _firebaseService.addProduct(product);
        await _sqliteService.markAsSynced(product.id);

        // Update the item in list to show "synced" status
        int index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index] = product.copyWith(isSynced: true);
        }
      }

      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Saved locally but error occurred: $e');
    }
  }

  // Sync all unsynced products
  Future<void> syncProducts() async {
    if (isSyncing.value) return; // Prevent double click

    isSyncing.value = true;
    try {
      // 1. Get all unsynced products from SQLite
      List<ProductModel> unsyncedProducts = await _sqliteService
          .getUnsyncedProducts();

      if (unsyncedProducts.isEmpty) {
        Get.snackbar('Info', 'All products are already synced');
        return;
      }

      // 2. Loop and upload
      for (var product in unsyncedProducts) {
        await _firebaseService.addProduct(product);
        await _sqliteService.markAsSynced(product.id);
      }

      // 3. Reload list to update UI icons
      await loadProducts();

      Get.snackbar(
        'Success',
        '${unsyncedProducts.length} Products synced successfully',
      );
    } catch (e) {
      Get.snackbar('Sync Error', e.toString());
    } finally {
      isSyncing.value = false;
    }
  }
}
