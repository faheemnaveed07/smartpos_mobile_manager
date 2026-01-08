import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/ledger_entry.dart';
import '../controllers/customer_controller.dart';
import '../widgets/ledger_entry_tile.dart';
import '../widgets/add_ledger_dialog.dart';

class CustomerDetailScreen extends StatelessWidget {
  CustomerDetailScreen({super.key});

  // Get customer from arguments
  final Customer customer = Get.arguments as Customer;
  final CustomerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    // Load ledger when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCustomerLedger(customer.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditCustomerDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Info Header
          _buildCustomerHeader(context),

          // Ledger History Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Ledger Entries List
          Expanded(
            child: Obx(() {
              if (controller.isLedgerLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final ledger = controller.customerLedger;
              if (ledger.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add udhaar or receive payment to see history',
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: ledger.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LedgerEntryTile(entry: ledger[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Customer info header widget
  Widget _buildCustomerHeader(BuildContext context) {
    final hasBalance = customer.outstandingBalance > 0;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasBalance
              ? [Colors.red.shade400, Colors.red.shade600]
              : [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (hasBalance ? Colors.red : Colors.green).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Customer avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Customer basic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (customer.email != null)
                      Text(
                        customer.email!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Outstanding balance
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Outstanding Balance',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  'Rs. ${customer.outstandingBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddEntryDialog(type: LedgerType.debit),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Udhaar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddEntryDialog(type: LedgerType.credit),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog({LedgerType? type}) {
    Get.dialog(AddLedgerEntryDialog(customer: customer, type: type));
  }

  void _showEditCustomerDialog() {
    Get.snackbar('Info', 'Edit customer coming soon');
  }
}
