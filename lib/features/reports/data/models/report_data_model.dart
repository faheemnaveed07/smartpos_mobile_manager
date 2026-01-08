import '../../domain/entities/report_data.dart';

// DTO extends Entity - Used for data mapping from JSON/SQLite
class ReportDataModel extends ReportData {
  ReportDataModel({
    required super.title,
    required super.summary,
    required super.chartSeries,
    required super.rawData,
  });

  // Factory: Convert from SQLite Map (when you connect real DB later)
  factory ReportDataModel.fromMap(Map<String, dynamic> map) {
    return ReportDataModel(
      title: map['title'],
      summary: Map<String, dynamic>.from(map['summary']),
      // For chartSeries - you'll need to parse from JSON string
      chartSeries: [], // TODO: Parse from map['chartData']
      rawData: List<Map<String, dynamic>>.from(map['rawData']),
    );
  }

  // Factory: Convert from Firestore Document
  factory ReportDataModel.fromFirestore(Map<String, dynamic> doc) {
    return ReportDataModel(
      title: doc['title'],
      summary: Map<String, dynamic>.from(doc['summary']),
      chartSeries: [], // TODO: Parse from doc['chartSeries']
      rawData: List<Map<String, dynamic>>.from(doc['rawData']),
    );
  }

  // To Map (for SQLite insertion)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      // 'chartSeries': jsonEncode(chartSeries), // TODO: Serialize
      'rawData': rawData,
    };
  }

  // CopyWith for updates
  ReportDataModel copyWith({
    String? title,
    Map<String, dynamic>? summary,
    List<ChartSeries>? chartSeries,
    List<Map<String, dynamic>>? rawData,
  }) {
    return ReportDataModel(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      chartSeries: chartSeries ?? this.chartSeries,
      rawData: rawData ?? this.rawData,
    );
  }
}
