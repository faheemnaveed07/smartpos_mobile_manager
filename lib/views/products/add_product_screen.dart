import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../core/utils/validators.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final ProductController _productController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TODO: Create text controllers for ALL fields
  // name, sku, buyingPrice, sellingPrice, stock, category

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
              // TODO: Add ALL fields:
              // 1. Product Name (TextFormField)
              // 2. SKU (TextFormField - hint: "IMEI/Model Number")
              // 3. Buying Price (TextFormField - keyboardType: number)
              // 4. Selling Price (TextFormField - keyboardType: number)
              // 5. Stock Quantity (TextFormField - keyboardType: number)
              // 6. Category Dropdown (DropdownButtonFormField)
              //    Categories: 'Mobile', 'Accessories', 'SIM', 'Charger'
              // 7. Image Picker Button (IconButton with image upload)
              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Create Product object and call _productController.addProduct()
                  }
                },
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
