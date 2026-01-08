import 'package:flutter/material.dart';
import '../../domain/entities/ledger_entry.dart';

class LedgerEntryTile extends StatelessWidget {
  final LedgerEntry entry;

  const LedgerEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDebit = entry.type == LedgerType.debit;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDebit ? Colors.red.shade100 : Colors.green.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDebit ? Colors.red.shade50 : Colors.green.shade50,
          child: Icon(
            isDebit ? Icons.arrow_upward : Icons.arrow_downward,
            color: isDebit ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          entry.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(entry.date),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isDebit ? '+' : '-'} Rs. ${entry.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDebit ? Colors.red[700] : Colors.green[700],
              ),
            ),
            Text(
              isDebit ? 'Udhaar' : 'Payment',
              style: TextStyle(
                fontSize: 10,
                color: isDebit ? Colors.red[400] : Colors.green[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
