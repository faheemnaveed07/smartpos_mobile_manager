import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/hero_sales_tile.dart';
import '../widgets/udhaar_tile.dart';
import '../widgets/stock_alert_tile.dart';
import '../widgets/sales_chart_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller via binding
    final controller = Get.find<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Dashboard'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
          // Sync status indicator
          Obx(() {
            final pending = controller.stats.value?.pendingSyncCount ?? 0;
            return IconButton(
              icon: Badge(
                label: Text('$pending'),
                isLabelVisible: pending > 0,
                child: const Icon(Icons.cloud_upload_outlined),
              ),
              onPressed: () {
                // TODO: Navigate to sync screen
              },
            );
          }),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on Dashboard
              break;
            case 1:
              Get.toNamed('/pos');
              break;
            case 2:
              Get.toNamed('/products');
              break;
            case 3:
              // TODO: Settings/More
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'POS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value && controller.stats.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = controller.stats.value;
          if (stats == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Hero Sales Tile (Full Width)
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: HeroSalesTile(
                    sales: stats.todaySales,
                    profit: stats.todayProfit,
                  ),
                ),
                const SizedBox(height: 16),

                // Two small tiles side by side
                Row(
                  children: [
                    // Udhaar Tile
                    Expanded(
                      child: SizedBox(
                        height: 150,
                        child: UdhaarTile(
                          totalReceivable: stats.totalReceivable,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Stock Alert Tile
                    Expanded(
                      child: SizedBox(
                        height: 150,
                        child: StockAlertTile(
                          lowStockCount: stats.lowStockCount,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Chart Tile (Full Width)
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: SalesChartTile(hourlyData: stats.hourlySales),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
