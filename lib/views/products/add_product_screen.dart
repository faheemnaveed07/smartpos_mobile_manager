import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Ensure image_picker is in pubspec.yaml
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../widgets/custom_text_field.dart'; // Import the widget created in Step 1

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controller Logic
  final ProductController _productController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController skuController;
  late TextEditingController buyingPriceController;
  late TextEditingController sellingPriceController;
  late TextEditingController stockController;

  // Selection Variables
  String? selectedCategory;
  File? selectedImage;

  // Categories List
  final List<String> categories = ['Mobile', 'Accessories', 'SIM', 'Charger'];

  @override
  void initState() {
    super.initState();
    // Check if we are editing an existing product
    final ProductModel? productToEdit = Get.arguments;

    // Initialize controllers with existing data or empty string
    nameController = TextEditingController(text: productToEdit?.name ?? '');
    skuController = TextEditingController(text: productToEdit?.sku ?? '');
    buyingPriceController = TextEditingController(
      text: productToEdit?.buyingPrice.toString() ?? '',
    );
    sellingPriceController = TextEditingController(
      text: productToEdit?.sellingPrice.toString() ?? '',
    );
    stockController = TextEditingController(
      text: productToEdit?.stock.toString() ?? '',
    );

    selectedCategory = productToEdit?.category;
    // Note: Image handling logic depends on how you store images (URL vs Local path)
    final String? imagePath = productToEdit?.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      selectedImage = File(imagePath);
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    nameController.dispose();
    skuController.dispose();
    buyingPriceController.dispose();
    sellingPriceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  // Method to Pick Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Get.arguments == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 7. Image Picker Button (Moved to top for better UI)
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : null,
                    child: selectedImage == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 1. Product Name
              CustomTextField(
                controller: nameController,
                label: 'Product Name',
                icon: Icons.shopping_bag,
                validator: (v) =>
                    v!.isEmpty ? "Product Name is required" : null,
              ),

              // 2. SKU
              CustomTextField(
                controller: skuController,
                label: 'SKU / Model No',
                icon: Icons.qr_code,
                hint: "IMEI/Model Number",
                validator: (v) => v!.isEmpty ? "SKU is required" : null,
              ),

              // 3 & 4. Prices (In a Row)
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: buyingPriceController,
                      label: 'Buying Price',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: sellingPriceController,
                      label: 'Selling Price',
                      icon: Icons.sell,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),

              // 5. Stock Quantity
              CustomTextField(
                controller: stockController,
                label: 'Stock Quantity',
                icon: Icons.inventory_2,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Stock is required" : null,
              ),

              // 6. Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Get original product if editing
                      final ProductModel? originalProduct = Get.arguments;

                      // Create Product Object
                      final ProductModel newProduct = ProductModel(
                        id:
                            originalProduct?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        sku: skuController.text.trim(),
                        buyingPrice:
                            double.tryParse(buyingPriceController.text) ?? 0.0,
                        sellingPrice:
                            double.tryParse(sellingPriceController.text) ?? 0.0,
                        stock: int.tryParse(stockController.text) ?? 0,
                        category: selectedCategory!,
                        imagePath: selectedImage?.path ?? '',
                        // Preserve original createdAt for edits, new for adds
                        createdAt: originalProduct?.createdAt ?? DateTime.now(),
                        isSynced: false, // Mark as unsynced since it's modified
                      );

                      // Call Controller - Add or Update
                      if (originalProduct == null) {
                        _productController.addProduct(newProduct);
                      } else {
                        _productController.updateProduct(newProduct);
                      }

                      Get.back(); // Close screen
                    }
                  },
                  child: const Text(
                    'Save Product',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
