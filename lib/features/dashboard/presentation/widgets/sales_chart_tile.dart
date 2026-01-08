import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smartpos_mobile_manager/features/dashboard/domain/entities/dashboard_stats.dart';

class SalesChartTile extends StatelessWidget {
  final List<HourlyData> hourlyData;

  const SalesChartTile({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'HOURLY SALES',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                _buildChartData(),
                duration: const Duration(seconds: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    // Generate spots from hourly data (only take some for cleaner chart)
    final filteredData = hourlyData
        .where((h) => h.hour >= 9 && h.hour <= 21)
        .toList();
    final spots = filteredData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value =
          entry.value.sales / 1000; // Scale down for better visualization
      return FlSpot(index, value);
    }).toList();

    if (spots.isEmpty) {
      return LineChartData();
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue[600],
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
