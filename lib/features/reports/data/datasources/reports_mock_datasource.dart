import '../../domain/entities/report_data.dart';
import 'package:flutter/material.dart';

class ReportsMockDataSource {
  // SALES SUMMARY - Today's mock data (mobile shop scenario)
  ReportData getSalesSummaryToday() {
    return ReportData(
      title: 'Sales Summary - Today',
      summary: {
        'Total Sales': 45000,
        'Tax': 4090.91,
        'Discount': 500,
        'Net Sales': 40409.09,
        'Invoices': 12,
        'Avg Sale': 3750,
      },
      chartSeries: [
        ChartSeries(
          name: 'Hourly Sales',
          color: Colors.blue,
          points: [
            DataPoint(label: '9AM', value: 2500),
            DataPoint(label: '11AM', value: 4500),
            DataPoint(label: '1PM', value: 8000), // Peak lunch time
            DataPoint(label: '3PM', value: 3200),
            DataPoint(label: '5PM', value: 5500),
            DataPoint(label: '7PM', value: 12000), // Evening peak
            DataPoint(label: '9PM', value: 9300),
          ],
        ),
      ],
      rawData: [
        {
          'Invoice': '#INV001',
          'Time': '09:30',
          'Amount': '₨ 2,500',
          'Items': 2,
        },
        {
          'Invoice': '#INV002',
          'Time': '10:15',
          'Amount': '₨ 4,500',
          'Items': 3,
        },
        {
          'Invoice': '#INV003',
          'Time': '12:45',
          'Amount': '₨ 8,000',
          'Items': 5,
        },
        // ... more rows for PDF
      ],
    );
  }

  // CUSTOMER LEDGER - Mock data with Udhaar
  ReportData getCustomerLedger() {
    return ReportData(
      title: 'Customer Ledger Summary',
      summary: {
        'Total Receivable': 85000, // Total Udhaar
        'Total Customers': 15,
        'Avg Balance': 5667,
      },
      chartSeries: [
        ChartSeries(
          name: 'Top 5 Debtors',
          color: Colors.red,
          points: [
            DataPoint(label: 'Ahmed Mobile', value: 15000),
            DataPoint(label: 'Kashif Store', value: 12000),
            DataPoint(label: 'Asif Telecom', value: 10000),
            DataPoint(label: 'Bilal Shop', value: 8000),
            DataPoint(label: 'Zain Mobile', value: 6500),
          ],
        ),
      ],
      rawData: [
        {
          'Name': 'Ahmed Mobile',
          'Phone': '0300-1234567',
          'Total Udhaar': '₨ 15,000',
        },
        {
          'Name': 'Kashif Store',
          'Phone': '0300-9876543',
          'Total Udhaar': '₨ 12,000',
        },
        {
          'Name': 'Asif Telecom',
          'Phone': '0300-5555555',
          'Total Udhaar': '₨ 10,000',
        },
        {
          'Name': 'Bilal Shop',
          'Phone': '0300-7777777',
          'Total Udhaar': '₨ 8,000',
        },
        {
          'Name': 'Zain Mobile',
          'Phone': '0300-9999999',
          'Total Udhaar': '₨ 6,500',
        },
      ],
    );
  }

  // STOCK VALUE - Mock data
  ReportData getStockValue() {
    return ReportData(
      title: 'Stock Value Report',
      summary: {
        'Total Items': 156,
        'Buying Value': 450000,
        'Selling Value': 580000,
        'Potential Profit': 130000,
        'Categories': 5,
      },
      chartSeries: [
        ChartSeries(
          name: 'Stock by Category',
          color: Colors.orange,
          points: [
            DataPoint(label: 'Mobile', value: 250000),
            DataPoint(label: 'Accessories', value: 80000),
            DataPoint(label: 'SIM', value: 50000),
            DataPoint(label: 'Charger', value: 45000),
            DataPoint(label: 'Parts', value: 25000),
          ],
        ),
      ],
      rawData: [
        {
          'SKU': 'MOB001',
          'Product': 'iPhone 13',
          'Stock': 5,
          'Buying': '₨ 80,000',
          'Selling': '₨ 95,000',
        },
        {
          'SKU': 'MOB002',
          'Product': 'Samsung A54',
          'Stock': 8,
          'Buying': '₨ 45,000',
          'Selling': '₨ 55,000',
        },
      ],
    );
  }

  // PROFIT & LOSS - Mock data
  ReportData getProfitLoss() {
    return ReportData(
      title: 'Profit & Loss Analysis',
      summary: {
        'Gross Profit': 130000,
        'Gross Margin': '29%',
        'Net Profit': 115000,
        'Net Margin': '26%',
        'Total Expenses': 15000,
      },
      chartSeries: [
        ChartSeries(
          name: 'Monthly Profit Trend',
          color: Colors.green,
          points: List.generate(6, (i) {
            return DataPoint(
              label: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'][i],
              value: [
                95000.0,
                110000.0,
                125000.0,
                130000.0,
                115000.0,
                130000.0,
              ][i],
            );
          }),
        ),
      ],
      rawData: [],
    );
  }

  // PRODUCT PERFORMANCE - Mock data
  ReportData getProductPerformance() {
    return ReportData(
      title: 'Product Performance Report',
      summary: {
        'Best Seller': 'iPhone 13',
        'Units Sold': 45,
        'Revenue Leader': 'iPhone 13',
        'Total Revenue': 4275000,
      },
      chartSeries: [
        ChartSeries(
          name: 'Top 5 Products',
          color: Colors.purple,
          points: [
            DataPoint(label: 'iPhone 13', value: 45),
            DataPoint(label: 'Samsung A54', value: 38),
            DataPoint(label: 'Oppo A17', value: 32),
            DataPoint(label: 'Infinix Hot', value: 28),
            DataPoint(label: 'Techno Spark', value: 25),
          ],
        ),
      ],
      rawData: [
        {
          'Product': 'iPhone 13',
          'Units Sold': 45,
          'Revenue': '₨ 4,275,000',
          'Profit': '₨ 675,000',
        },
        {
          'Product': 'Samsung A54',
          'Units Sold': 38,
          'Revenue': '₨ 2,090,000',
          'Profit': '₨ 380,000',
        },
      ],
    );
  }
}
