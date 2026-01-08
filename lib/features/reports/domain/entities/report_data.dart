import 'package:flutter/material.dart';

// Flexible entity for ANY report type
class ReportData {
  final String title;
  final Map<String, dynamic> summary; // Key-value metrics
  final List<ChartSeries> chartSeries; // For charts
  final List<Map<String, dynamic>> rawData; // For tables/PDF

  ReportData({
    required this.title,
    required this.summary,
    required this.chartSeries,
    required this.rawData,
  });
}

// Chart data series
class ChartSeries {
  final String name; // Series name (e.g., "Sales", "Stock")
  final List<DataPoint> points;
  final Color color;

  ChartSeries({required this.name, required this.points, required this.color});
}

class DataPoint {
  final String label; // X-axis label (hour, category)
  final double value; // Y-axis value

  DataPoint({required this.label, required this.value});
}
