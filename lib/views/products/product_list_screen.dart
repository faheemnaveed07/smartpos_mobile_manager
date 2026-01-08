import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart'; // Ensure package added
import 'package:flutter_slidable/flutter_slidable.dart'; // Ensure package added
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'add_product_screen.dart'; // Import zaroori hai

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  // 🔥 FIX 1: Get.put() use karein taakay Controller create ho jaye
  final ProductController _productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Inventory'),
        actions: [
          // Sync button
          Obx(() {
            if (_productController.isSyncing.value) {
              return const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () => _productController.syncProducts(),
            );
          }),
        ],
      ),

      // Floating add button
      floatingActionButton: FloatingActionButton(
        // 🔥 FIX 2: Direct Navigation use karein
        onPressed: () => Get.to(() => const AddProductScreen()),
        child: const Icon(Icons.add),
      ),

      // Product list
      body: Obx(() {
        if (_productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_productController.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Text("Click + to add offline"),
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

  // Product card widget
  Widget _buildProductCard(ProductModel product) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            // Edit action
            SlidableAction(
              onPressed: (context) =>
                  Get.to(() => const AddProductScreen(), arguments: product),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            // Product image
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  (product.imagePath != null && product.imagePath!.isNotEmpty)
                  ? FileImage(File(product.imagePath!))
                  : null,
              child: (product.imagePath == null || product.imagePath!.isEmpty)
                  ? const Icon(Icons.image, size: 30, color: Colors.grey)
                  : null,
            ),
            // Product info
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'SKU: ${product.sku}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(
                    color: product.stock < 5 ? Colors.red : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Price aur status
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${product.sellingPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                // Sync status indicator
                Icon(
                  product.isSynced ? Icons.cloud_done : Icons.cloud_off,
                  size: 18,
                  color: product.isSynced ? Colors.blue : Colors.grey,
                ),
              ],
            ),
            onTap: () {
              // Tap par edit screen kholne ke liye
              Get.to(() => const AddProductScreen(), arguments: product);
            },
          ),
        ),
      ),
    );
  }

  // Delete confirmation dialog
  void _showDeleteDialog(String id) {
    Get.defaultDialog(
      title: 'Delete Product?',
      middleText: 'This will delete the product locally and from cloud.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        // 🔥 FIX 3: Calling delete method from controller
        // Note: Ensure deleteProduct method exists in ProductController
        // _productController.deleteProduct(id);
        Get.back();
        Get.snackbar(
          "Info",
          "Delete logic implementation pending in Controller",
        );
      },
    );
  }
}
