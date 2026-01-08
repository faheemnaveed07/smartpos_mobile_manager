import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static Future<File> generateReport({
    required String title,
    required List<Map<String, String>> headers,
    required List<List<String>> data,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    // Load a font that supports currency symbols if needed (Optional)
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    final tableHeaders = headers.map((h) => h['label']!).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [
                    PdfColor.fromInt(0xFFE3F2FD),
                    PdfColor.fromInt(0xFFFFFFFF),
                  ],
                  begin: pw.Alignment.topCenter,
                  end: pw.Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "SMART POS",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      "Manager Dashboard",
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    "REPORT",
                    style: pw.TextStyle(
                      color: PdfColors.blue900,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Generated: ${DateTime.now().toString().split('.')[0]}",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.Divider(color: PdfColors.blue900),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: data,
            border: null,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            cellPadding: const pw.EdgeInsets.all(8),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight, // Amounts usually on right
              2: pw.Alignment.centerRight,
            },
          ),
        ],
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                "Powered by SmartPOS App",
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ),
          ],
        ),
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> shareViaWhatsApp(File file, {String message = ''}) async {
    await Share.shareXFiles([XFile(file.path)], text: message);
  }
}
