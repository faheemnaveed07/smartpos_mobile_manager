import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/reports_controller.dart';
import '../widgets/sales_trend_chart.dart';
import '../../domain/entities/report_data.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.find<ReportsController>();

  // Currency Formatter (Pakistan)
  final currency = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      controller.changeTab(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Business Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          // PDF Export Button
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.exportToPDF(
                      _tabController.index == 0
                          ? controller.salesData.value
                          : _tabController.index == 1
                          ? controller.stockData.value
                          : controller.ledgerData.value,
                    ),
              tooltip: 'Export to PDF & Share',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              icon: Icon(Icons.trending_up, color: Colors.greenAccent[400]),
              text: 'Sales',
            ),
            Tab(
              icon: Icon(Icons.inventory_2, color: Colors.orangeAccent[400]),
              text: 'Stock',
            ),
            Tab(
              icon: Icon(Icons.people, color: Colors.cyanAccent[400]),
              text: 'Ledger',
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.salesData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [_buildSalesTab(), _buildStockTab(), _buildLedgerTab()],
        );
      }),
    );
  }

  // ==================== SALES TAB ====================
  Widget _buildSalesTab() {
    final data = controller.salesData.value;
    if (data == null) return const Center(child: Text('No Sales Data'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Sales Trend Chart
        _sectionTitle('Sales Trend', Icons.show_chart),
        const SizedBox(height: 12),
        SalesTrendChart(series: data.chartSeries.first),
        const SizedBox(height: 24),

        // 2. Summary Metrics Grid (4 cards)
        _sectionTitle('Today\'s Overview', Icons.dashboard),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildMetricCard(
              'Total Sales',
              currency.format(data.summary['Total Sales'] ?? 0),
              Icons.attach_money,
              Colors.green,
            ),
            _buildMetricCard(
              'Net Sales',
              currency.format(data.summary['Net Sales'] ?? 0),
              Icons.wallet,
              Colors.blue,
            ),
            _buildMetricCard(
              'Invoices',
              '${data.summary['Invoices'] ?? 0}',
              Icons.receipt_long,
              Colors.orange,
            ),
            _buildMetricCard(
              'Avg. Sale',
              currency.format(data.summary['Avg Sale'] ?? 0),
              Icons.analytics,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 3. Data Table
        _sectionTitle('Recent Transactions', Icons.list_alt),
        const SizedBox(height: 12),
        _buildDataTable(data.rawData, ['Invoice', 'Time', 'Amount', 'Items']),
      ],
    );
  }

  // ==================== STOCK TAB ====================
  Widget _buildStockTab() {
    final data = controller.stockData.value;
    if (data == null) return const Center(child: Text('Loading Stock Data...'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Stock by Category Chart (Pie Chart)
        _sectionTitle('Stock by Category', Icons.pie_chart),
        const SizedBox(height: 12),
        _buildPieChart(data.chartSeries.first),
        const SizedBox(height: 24),

        // 2. Stock Summary Cards
        _sectionTitle('Stock Summary', Icons.inventory),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildMetricCard(
              'Total Items',
              '${data.summary['Total Items'] ?? 0}',
              Icons.inventory_2,
              Colors.blue,
            ),
            _buildMetricCard(
              'Buying Value',
              currency.format(data.summary['Buying Value'] ?? 0),
              Icons.shopping_cart,
              Colors.orange,
            ),
            _buildMetricCard(
              'Selling Value',
              currency.format(data.summary['Selling Value'] ?? 0),
              Icons.sell,
              Colors.green,
            ),
            _buildMetricCard(
              'Potential Profit',
              currency.format(data.summary['Potential Profit'] ?? 0),
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 3. Stock Table
        _sectionTitle('Top Products by Value', Icons.table_chart),
        const SizedBox(height: 12),
        _buildDataTable(data.rawData, [
          'SKU',
          'Product',
          'Stock',
          'Buying',
          'Selling',
        ]),
      ],
    );
  }

  // ==================== LEDGER TAB ====================
  Widget _buildLedgerTab() {
    final data = controller.ledgerData.value;
    if (data == null) return const Center(child: Text('No Ledger Data'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Summary Cards
        _sectionTitle('Udhaar Summary', Icons.account_balance_wallet),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Receivable',
                currency.format(data.summary['Total Receivable'] ?? 0),
                Icons.money_off,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Customers',
                '${data.summary['Total Customers'] ?? 0}',
                Icons.people,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 2. Horizontal Bar Chart (Top Debtors)
        _sectionTitle('Top 5 Debtors', Icons.bar_chart),
        const SizedBox(height: 12),
        _buildHorizontalBarChart(data.chartSeries.first),
        const SizedBox(height: 24),

        // 3. Udhaar Table
        _sectionTitle('Customer Balances', Icons.table_chart),
        const SizedBox(height: 12),
        _buildDataTable(data.rawData, ['Name', 'Phone', 'Total Udhaar']),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    List<Map<String, dynamic>> data,
    List<String> columns,
  ) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No data available')),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
            columns: columns
                .map(
                  (col) => DataColumn(
                    label: Text(
                      col,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            rows: data.map((row) {
              return DataRow(
                cells: columns.map((col) {
                  return DataCell(Text('${row[col] ?? ''}'));
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(ChartSeries series) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pie Chart - Left side (smaller)
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: series.points.asMap().entries.map((e) {
                  final colors = [
                    Colors.blue,
                    Colors.orange,
                    Colors.green,
                    Colors.purple,
                    Colors.red,
                  ];
                  return PieChartSectionData(
                    value: e.value.value,
                    title: '',
                    color: colors[e.key % colors.length],
                    radius: 50,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Legend - Right side (more space)
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: series.points.asMap().entries.map((e) {
                final colors = [
                  Colors.blue,
                  Colors.orange,
                  Colors.green,
                  Colors.purple,
                  Colors.red,
                ];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          e.value.label,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBarChart(ChartSeries series) {
    final maxValue = series.points
        .map((p) => p.value)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: series.points.map((point) {
          final percentage = (point.value / maxValue);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    point.label,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            currency.format(point.value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
