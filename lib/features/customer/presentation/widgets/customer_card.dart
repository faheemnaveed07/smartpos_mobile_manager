import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/ledger_entry.dart';
import 'add_ledger_dialog.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final bool hasBalance = customer.outstandingBalance > 0;

    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasBalance ? Colors.red.shade200 : Colors.green.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          // Customer avatar
          leading: CircleAvatar(
            backgroundColor: customer.type == 'WALK_IN'
                ? Colors.grey
                : Colors.blue,
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Customer info
          title: Text(
            customer.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.phone),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: customer.type == 'WALK_IN'
                      ? Colors.grey.shade100
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  customer.type == 'WALK_IN' ? 'Walk-in' : 'Regular',
                  style: TextStyle(
                    fontSize: 10,
                    color: customer.type == 'WALK_IN'
                        ? Colors.grey[700]
                        : Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          // Outstanding balance
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${customer.outstandingBalance.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasBalance ? Colors.red[700] : Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasBalance ? 'Due' : 'Clear',
                style: TextStyle(
                  fontSize: 11,
                  color: hasBalance ? Colors.red[400] : Colors.green[400],
                ),
              ),
            ],
          ),
          // Tap to view details OR long press for quick actions
          onTap: () => Get.toNamed('/customer-detail', arguments: customer),
          onLongPress: () => _showQuickActions(context),
        ),
      ),
    );
  }

  // Quick actions dialog (add udhaar/payment)
  void _showQuickActions(BuildContext context) {
    Get.defaultDialog(
      title: 'Quick Action',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          Text(customer.name, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.red),
            title: const Text('Add Udhaar'),
            onTap: () {
              Get.back();
              Get.dialog(
                AddLedgerEntryDialog(
                  customer: customer,
                  type: LedgerType.debit,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined, color: Colors.green),
            title: const Text('Receive Payment'),
            onTap: () {
              Get.back();
              Get.dialog(
                AddLedgerEntryDialog(
                  customer: customer,
                  type: LedgerType.credit,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
