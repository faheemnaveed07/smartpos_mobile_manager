import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smartpos_mobile_manager/features/dashboard/presentation/controllers/dashboard_controller.dart';

class HeroSalesTile extends StatelessWidget {
  final double sales;
  final double profit;

  const HeroSalesTile({super.key, required this.sales, required this.profit});

  @override
  Widget build(BuildContext context) {
    return BounceInDown(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'TODAY\'S SALES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Sales number (animated)
            Obx(() {
              final controller = Get.find<DashboardController>();
              return Text(
                'Rs. ${controller.animatedSales.value.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),
            // Profit number (animated)
            Obx(() {
              final controller = Get.find<DashboardController>();
              return Text(
                'Profit: Rs. ${controller.animatedProfit.value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
