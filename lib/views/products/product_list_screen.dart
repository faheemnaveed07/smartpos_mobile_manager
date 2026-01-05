import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Sync button (line 15)
          Obx(() {
            if (_productController.isSyncing.value) {
              return const CircularProgressIndicator(color: Colors.white);
            }
            return IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () => _productController.syncProducts(),
            );
          }),
        ],
      ),

      // Floating add button (line 27)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-product'),
        child: const Icon(Icons.add),
      ),

      // Product list (line 32)
      body: Obx(() {
        if (_productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_productController.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No products yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: _productController.products.length,
          itemBuilder: (context, index) {
            final product = _productController.products[index];
            return _buildProductCard(product);
          },
        );
      }),
    );
  }

  // Product card widget (line 63)
  Widget _buildProductCard(Product product) {
    return FadeInUp(
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            // Edit action
            SlidableAction(
              onPressed: (context) =>
                  Get.toNamed('/edit-product', arguments: product),
              backgroundColor: Colors.blue,
              icon: Icons.edit,
              label: 'Edit',
            ),
            // Delete action
            SlidableAction(
              onPressed: (context) => _showDeleteDialog(product.id),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            // Product image (line 89)
            leading: product.imageUrl != null
                ? Image.network(product.imageUrl!, width: 50, height: 50)
                : const Icon(
                    Icons.mobile_friendly,
                    size: 50,
                  ), // Mobile shop icon
            // Product info (line 94)
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('SKU: ${product.sku}\nStock: ${product.stock}'),

            // Price aur status (line 100)
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Rs. ${product.sellingPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                // Sync status indicator (line 112)
                Icon(
                  product.isSynced ? Icons.cloud_done : Icons.cloud_off,
                  size: 20,
                  color: product.isSynced ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Delete confirmation dialog (line 121)
  void _showDeleteDialog(String id) {
    Get.defaultDialog(
      title: 'Delete Product?',
      middleText: 'Are you sure you want to delete this product?',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            // TODO: Call delete method
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
