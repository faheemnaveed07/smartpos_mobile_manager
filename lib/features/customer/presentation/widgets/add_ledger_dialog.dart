import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/ledger_entry.dart';
import '../controllers/customer_controller.dart';

class AddLedgerEntryDialog extends StatelessWidget {
  final Customer customer;
  final LedgerType? type; // Pre-select type if provided

  AddLedgerEntryDialog({super.key, required this.customer, this.type});

  final CustomerController controller = Get.find();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Rx<LedgerType> selectedType = LedgerType.debit.obs;

  @override
  Widget build(BuildContext context) {
    // Initialize type if provided
    if (type != null) {
      selectedType.value = type!;
    }

    final isPayment = type == LedgerType.credit;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isPayment ? Icons.payments : Icons.add_circle_outline,
                  color: isPayment ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isPayment ? 'Receive Payment' : 'Add Udhaar',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // Customer info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          customer.phone,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Balance', style: TextStyle(fontSize: 10)),
                      Text(
                        'Rs. ${customer.outstandingBalance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: customer.outstandingBalance > 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount field
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount (Rs.)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: isPayment
                    ? 'e.g., Cash payment'
                    : 'e.g., Mobile purchase',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _submitEntry(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPayment ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isPayment ? 'Receive' : 'Add Udhaar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitEntry() {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter amount');
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter valid amount');
      return;
    }

    controller.addLedgerEntry(
      customerId: customer.id,
      amount: amount,
      type: selectedType.value,
      description: descriptionController.text.isNotEmpty
          ? descriptionController.text
          : (selectedType.value == LedgerType.debit
                ? 'Udhaar added'
                : 'Payment received'),
    );
    Get.back(); // Close dialog
  }
}
