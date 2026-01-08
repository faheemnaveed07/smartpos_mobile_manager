import 'package:get/get.dart';
import 'auth_controller.dart';
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

  // Helper method to check if online (with fallback)
  Future<bool> _checkOnline() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        return await Get.find<AuthController>().isOnline();
      }
      return true; // Default to online if AuthController not available
    } catch (e) {
      print('Online check error: $e');
      return true; // Default to online
    }
  }

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
      bool isOnline = await _checkOnline();

      if (isOnline) {
        bool synced = await _firebaseService.addProduct(product);
        if (synced) {
          await _sqliteService.markAsSynced(product.id);

          // Update the item in list to show "synced" status
          int index = products.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            products[index] = product.copyWith(isSynced: true);
          }
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

      int successCount = 0;
      int failCount = 0;

      // 2. Loop and upload with proper error handling
      for (var product in unsyncedProducts) {
        bool success = await _firebaseService.addProduct(product);
        if (success) {
          await _sqliteService.markAsSynced(product.id);
          successCount++;
        } else {
          failCount++;
        }
      }

      // 3. Reload list to update UI icons
      await loadProducts();

      if (failCount == 0) {
        Get.snackbar('Success', '$successCount Products synced successfully');
      } else {
        Get.snackbar(
          'Partial Sync',
          '$successCount synced, $failCount failed. Check Firebase Console.',
        );
      }
    } catch (e) {
      Get.snackbar('Sync Error', e.toString());
    } finally {
      isSyncing.value = false;
    }
  }

  // Update product (offline-first)
  Future<void> updateProduct(ProductModel product) async {
    try {
      // 1. Update locally first (mark as unsynced for later sync)
      final updatedProduct = product.copyWith(isSynced: false);
      await _sqliteService.updateProduct(updatedProduct);

      // 2. Update in UI list
      int index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = updatedProduct;
      }

      // 3. Try to sync to Firebase if online
      bool isOnline = await _checkOnline();
      if (isOnline) {
        bool synced = await _firebaseService.updateProduct(product);
        if (synced) {
          await _sqliteService.markAsSynced(product.id);

          // Update synced status in list
          if (index != -1) {
            products[index] = product.copyWith(isSynced: true);
          }
        }
      }

      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Update error: $e');
    }
  }

  // Delete product (offline-first)
  Future<void> deleteProduct(String id) async {
    try {
      // 1. Remove from local DB
      await _sqliteService.deleteProduct(id);

      // 2. Remove from UI list
      products.removeWhere((p) => p.id == id);

      // 3. Try to delete from Firebase if online
      bool isOnline = await _checkOnline();
      if (isOnline) {
        await _firebaseService.deleteProduct(id);
      }

      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Delete error: $e');
    }
  }
}
