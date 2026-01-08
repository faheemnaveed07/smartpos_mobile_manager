import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/pos_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/cart_item_model.dart';

class POSScreen extends StatelessWidget {
  POSScreen({super.key});

  final POSController _posController = Get.put(POSController());
  final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          // Cart badge button
          Obx(() {
            final cartCount = _posController.cart.length;
            return IconButton(
              icon: Badge(
                label: Text('$cartCount'),
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () => _showCartBottomSheet(context),
            );
          }),
          // Clear cart button
          Obx(() {
            if (_posController.cart.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _posController.clearCart(),
                tooltip: 'Clear Cart',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 8),

          // Category chips
          _buildCategoryChips(),
          const SizedBox(height: 8),

          // Product grid
          Expanded(child: _buildProductGrid()),
        ],
      ),

      // Floating checkout button
      floatingActionButton: Obx(() {
        if (_posController.cart.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showCheckoutDialog(),
          icon: const Icon(Icons.payment),
          label: Text('Rs. ${_posController.grandTotal.toStringAsFixed(0)}'),
          backgroundColor: Colors.green,
        );
      }),
    );
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextField(
          onChanged: (value) => _posController.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Search by name...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

  // Category chips
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _posController.categories.length,
        itemBuilder: (context, index) {
          final category = _posController.categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Obx(() {
              final isSelected =
                  _posController.selectedCategory.value == category;
              return ChoiceChip(
                label: Text(category, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _posController.selectedCategory.value = category;
                  }
                },
                padding: const EdgeInsets.symmetric(horizontal: 8),
              );
            }),
          );
        },
      ),
    );
  }

  // Product grid - Mobile friendly 2 columns
  Widget _buildProductGrid() {
    return Obx(() {
      // Loading state
      if (_productController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final products = _posController.filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns for mobile
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: InkWell(
              onTap: () {
                _posController.addToCart(product);
                // Show mini feedback
                Get.snackbar(
                  'Added',
                  '${product.name} added to cart',
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(8),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: product.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholderIcon(),
                                  ),
                                )
                              : _buildPlaceholderIcon(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Product info
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Rs. ${product.sellingPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory,
                                  size: 12,
                                  color: product.stock < 5
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stock: ${product.stock}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: product.stock < 5
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(Icons.smartphone, size: 40, color: Colors.grey[400]),
    );
  }

  // Cart Bottom Sheet
  void _showCartBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Obx(
                    () => Text(
                      '${_posController.cart.length} items',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Cart items
            Expanded(
              child: Obx(() {
                if (_posController.cart.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('Cart is empty'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: _posController.cart.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final item = _posController.cart[index];
                    return _buildCartItem(item);
                  },
                );
              }),
            ),
            // Totals and Checkout
            _buildCartFooter(),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Cart item widget
  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Quantity circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rs. ${item.product.sellingPrice.toStringAsFixed(0)} each',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  onPressed: () =>
                      _posController.updateQuantity(item.product.id, -1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: () =>
                      _posController.updateQuantity(item.product.id, 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Cart footer with totals
  Widget _buildCartFooter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('Rs. ${_posController.subtotal.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax (10%)'),
                Text('Rs. ${_posController.tax.toStringAsFixed(0)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Rs. ${_posController.grandTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _posController.cart.isEmpty
                    ? null
                    : () {
                        Get.back();
                        _showCheckoutDialog();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CHECKOUT',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Checkout dialog
  void _showCheckoutDialog() {
    Get.defaultDialog(
      title: 'Confirm Sale',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items:'),
                Obx(() => Text('${_posController.cart.length}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Text(
                    'Rs. ${_posController.grandTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Payment method dropdown
            Obx(
              () => DropdownButtonFormField<String>(
                value: _posController.selectedPaymentMethod.value,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: ['Cash', 'Card', 'UPI'].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _posController.selectedPaymentMethod.value = value;
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        Obx(
          () => ElevatedButton(
            onPressed: _posController.isProcessing.value
                ? null
                : () async {
                    Get.back();
                    await _posController.checkout();
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: _posController.isProcessing.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
