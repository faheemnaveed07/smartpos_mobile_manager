import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
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
          // Clear cart button (line 16)
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

      // Body: Product Grid + Cart Side Panel (line 28)
      body: Row(
        children: [
          // Left: Products (70% width) (line 31)
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // Search bar (line 35)
                _buildSearchBar(),
                const SizedBox(height: 16),

                // Category chips (line 38)
                _buildCategoryChips(),
                const SizedBox(height: 16),

                // Product grid (line 41)
                Expanded(
                  child: Obx(() {
                    if (_productController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildProductGrid();
                  }),
                ),
              ],
            ),
          ),

          // Right: Cart (30% width) (line 53)
          Expanded(
            flex: 3,
            child: GlassContainer(
              blur: 15,
              child: Obx(() => _buildCartPanel()),
            ),
          ),
        ],
      ),
    );
  }

  // Search bar widget (line 63)
  Widget _buildSearchBar() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          onChanged: (value) => _posController.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Search by name or SKU...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }

  // Category chips (line 79)
  Widget _buildCategoryChips() {
    return FadeInUp(
      child: SizedBox(
        height: 50,
        child: Obx(() {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _posController.categories.length,
            itemBuilder: (context, index) {
              final category = _posController.categories[index];
              final isSelected =
                  _posController.selectedCategory.value == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _posController.selectedCategory.value = category;
                    }
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // Product grid (line 105)
  Widget _buildProductGrid() {
    return Obx(() {
      final products = _posController.filteredProducts;

      if (products.isEmpty) {
        return const Center(child: Text('No products found'));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return BounceInUp(
            child: InkWell(
              onTap: () => _posController.addToCart(product),
              child: Card(
                elevation: 4,
                child: Column(
                  children: [
                    // Product image (line 129)
                    Expanded(
                      child: product.imagePath != null
                          ? Image.network(product.imagePath!, fit: BoxFit.cover)
                          : Icon(
                              Icons.smartphone,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                    ),
                    // Product info (line 135)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rs. ${product.sellingPrice.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.green),
                          ),
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.stock < 5
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // Cart panel widget (line 158)
  Widget _buildCartPanel() {
    if (_posController.cart.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Cart is empty'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Cart header (line 173)
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Shopping Cart',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // Cart items list (line 180)
        Expanded(
          child: ListView.builder(
            itemCount: _posController.cart.length,
            itemBuilder: (context, index) {
              final item = _posController.cart[index];
              return _buildCartItem(item);
            },
          ),
        ),

        // Totals (line 188)
        _buildTotals(),

        // Checkout button (line 191)
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _showCheckoutDialog(),
            child: const Text('CHECKOUT', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  // Cart item widget (line 199)
  Widget _buildCartItem(CartItem item) {
    return FadeInLeft(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Text('${item.quantity}x')),
          title: Text(item.product.name),
          subtitle: Text('Rs. ${item.product.sellingPrice}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button (line 215)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () =>
                    _posController.updateQuantity(item.product.id, -1),
              ),
              // Increase button (line 219)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () =>
                    _posController.updateQuantity(item.product.id, 1),
              ),
              // Remove button (line 223)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _posController.updateQuantity(
                  item.product.id,
                  -item.quantity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Totals section (line 231)
  Widget _buildTotals() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', _posController.subtotal),
          _buildTotalRow('Tax (10%)', _posController.tax),
          const Divider(),
          _buildTotalRow(
            'Grand Total',
            _posController.grandTotal,
            isBold: true,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // Helper row builder (line 246)
  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Checkout dialog (line 263)
  void _showCheckoutDialog() {
    Get.defaultDialog(
      title: 'Confirm Sale',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Items: ${_posController.cart.length}'),
          Text(
            'Grand Total: Rs. ${_posController.grandTotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 16),
          // Payment method dropdown
          Obx(
            () => DropdownButtonFormField<String>(
              value: _posController.selectedPaymentMethod.value,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
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
            child: _posController.isProcessing.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm & Print'),
          ),
        ),
      ],
    );
  }
}
