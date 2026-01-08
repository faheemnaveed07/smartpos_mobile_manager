import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/controllers/customer_controller.dart';
import '../widgets/customer_card.dart';
import '../widgets/add_customer_dialog.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers & Ledger'),
        actions: [
          // Total receivable summary
          Obx(() {
            final total = controller.customers.fold(
              0.0,
              (sum, c) => sum + c.outstandingBalance,
            );
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rs. ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Total Due', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(AddCustomerDialog()),
        child: const Icon(Icons.person_add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 100, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No customers yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Add customers to track udhaar and payments'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadCustomers,
          child: ListView.builder(
            itemCount: controller.customers.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final customer = controller.customers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomerCard(customer: customer),
              );
            },
          ),
        );
      }),
    );
  }
}
