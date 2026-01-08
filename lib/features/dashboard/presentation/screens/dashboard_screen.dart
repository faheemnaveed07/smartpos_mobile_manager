import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/hero_sales_tile.dart';
import '../widgets/udhaar_tile.dart';
import '../widgets/stock_alert_tile.dart';
import '../widgets/sales_chart_tile.dart';
import '../widgets/quick_action_button.dart';
import '../../../../widgets/sync_indicator.dart';

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
          // Sync status indicator
          const SyncIndicator(),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
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
              // Show More Menu
              _showMoreMenu(context);
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

                // Quick Actions Section
                _buildQuickActions(),
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

  // Quick Actions Grid
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.people_outline,
                label: 'Customers',
                onTap: () => Get.toNamed('/customers'),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.add_shopping_cart,
                label: 'New Sale',
                onTap: () => Get.toNamed('/pos'),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.add_box_outlined,
                label: 'Add Product',
                onTap: () => Get.toNamed('/add-product'),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.analytics_outlined,
                label: 'Reports',
                onTap: () => Get.toNamed('/reports'),
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // More Menu Bottom Sheet
  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'More Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Menu Items
            _buildMenuItem(
              icon: Icons.people_outline,
              title: 'Customers & Ledger',
              subtitle: 'Manage udhaar and payments',
              color: Colors.orange,
              onTap: () {
                Get.back();
                Get.toNamed('/customers');
              },
            ),
            _buildMenuItem(
              icon: Icons.receipt_long,
              title: 'Sales History',
              subtitle: 'View past transactions',
              color: Colors.blue,
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Coming Soon',
                  'Sales history feature coming soon',
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.bar_chart,
              title: 'Reports',
              subtitle: 'Sales and profit reports',
              color: Colors.purple,
              onTap: () {
                Get.back();
                Get.toNamed('/reports');
              },
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences',
              color: Colors.grey,
              onTap: () {
                Get.back();
                Get.snackbar('Coming Soon', 'Settings feature coming soon');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
