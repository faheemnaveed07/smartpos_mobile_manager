import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class StockAlertTile extends StatelessWidget {
  final int lowStockCount;

  const StockAlertTile({super.key, required this.lowStockCount});

  @override
  Widget build(BuildContext context) {
    final bool hasAlert = lowStockCount > 0;

    return FadeInRight(
      child: Container(
        decoration: BoxDecoration(
          color: hasAlert ? Colors.orange.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasAlert ? Colors.orange.shade200 : Colors.green.shade200,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: hasAlert ? Colors.orange[600] : Colors.green[600],
              size: 24,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOCK ALERTS',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$lowStockCount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: hasAlert
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'low',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
