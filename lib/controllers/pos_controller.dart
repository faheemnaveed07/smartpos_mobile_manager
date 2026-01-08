import 'package:get/get.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../services/sale_sqlite_service.dart';
import '../services/sale_firebase_service.dart';
import 'product_controller.dart';
import 'auth_controller.dart';

class POSController extends GetxController {
  // Dependencies
  final ProductController _productController = Get.find();
  final SaleSQLiteService _sqliteService = SaleSQLiteService();
  final SaleFirebaseService _firebaseService = SaleFirebaseService();

  // Observables
  final RxList<CartItem> cart = <CartItem>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedPaymentMethod = 'Cash'.obs;
  final RxBool isProcessing = false.obs;

  // Helper method to check if online
  Future<bool> _checkOnline() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        return await Get.find<AuthController>().isOnline();
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  // Filtered products (mobile shop ke liye)
  List<ProductModel> get filteredProducts {
    List<ProductModel> result = _productController.products.toList();

    // Category filter
    if (selectedCategory.value != 'All') {
      result = result
          .where((p) => p.category == selectedCategory.value)
          .toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                p.sku.toLowerCase().contains(searchQuery.value.toLowerCase()),
          )
          .toList();
    }

    return result;
  }

  // Categories for mobile shop
  final List<String> categories = [
    'All',
    'Mobile',
    'Accessories',
    'SIM',
    'Charger',
    'Repair Parts',
  ];

  // Add to cart
  void addToCart(ProductModel product) {
    // Check if product already in cart
    int existingIndex = cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Increase quantity
      CartItem existingItem = cart[existingIndex];

      // Check stock availability
      if (existingItem.quantity < product.stock) {
        cart[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        Get.snackbar(
          'Stock Limit',
          'Cannot add more. Only ${product.stock} in stock.',
        );
      }
    } else {
      // Check if in stock
      if (product.stock > 0) {
        cart.add(CartItem(product: product, quantity: 1));
      } else {
        Get.snackbar('Out of Stock', '${product.name} is out of stock.');
      }
    }
  }

  // Update quantity
  void updateQuantity(String productId, int change) {
    int index = cart.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      CartItem item = cart[index];
      int newQuantity = item.quantity + change;

      if (newQuantity <= 0) {
        // Remove item from cart
        cart.removeAt(index);
      } else if (newQuantity <= item.product.stock) {
        // Update quantity
        cart[index] = item.copyWith(quantity: newQuantity);
      } else {
        Get.snackbar('Stock Limit', 'Only ${item.product.stock} available.');
      }
    }
  }

  // Apply discount to cart item
  void applyDiscount(String productId, double discount) {
    int index = cart.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      CartItem item = cart[index];
      cart[index] = item.copyWith(discount: discount);
    }
  }

  // Clear cart
  void clearCart() => cart.clear();

  // Calculate totals
  double get subtotal => cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.10; // 10% tax
  double get grandTotal => subtotal + tax;

  // Checkout (Offline-First)
  Future<void> checkout() async {
    if (cart.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return;
    }

    isProcessing.value = true;

    try {
      // 1. Create Sale object
      final sale = Sale.fromCartItems(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cartItems: cart.toList(),
        customerId: 'WALK_IN',
        paymentMethod: selectedPaymentMethod.value,
      );

      // 2. Save to SQLite (Offline First)
      await _sqliteService.insertSale(sale);

      // 3. Update product stock locally
      for (var item in cart) {
        int newStock = item.product.stock - item.quantity;
        ProductModel updatedProduct = item.product.copyWith(stock: newStock);
        await _productController.updateProduct(updatedProduct);
      }

      // 4. Try to sync to Firebase
      bool isOnline = await _checkOnline();
      if (isOnline) {
        bool synced = await _firebaseService.addSale(sale);
        if (synced) {
          await _sqliteService.markSaleAsSynced(sale.id);
        }
      }

      // 5. Clear cart and show success
      clearCart();

      Get.snackbar(
        'Sale Complete! 🎉',
        'Total: Rs. ${sale.grandTotal.toStringAsFixed(0)}',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Error', 'Checkout failed: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  // Sync all unsynced sales
  Future<void> syncSales() async {
    try {
      List<Sale> unsyncedSales = await _sqliteService.getUnsyncedSales();

      if (unsyncedSales.isEmpty) {
        Get.snackbar('Info', 'All sales are already synced');
        return;
      }

      int successCount = 0;
      for (var sale in unsyncedSales) {
        bool success = await _firebaseService.addSale(sale);
        if (success) {
          await _sqliteService.markSaleAsSynced(sale.id);
          successCount++;
        }
      }

      Get.snackbar(
        'Sync Complete',
        '$successCount/${unsyncedSales.length} sales synced',
      );
    } catch (e) {
      Get.snackbar('Sync Error', e.toString());
    }
  }
}
