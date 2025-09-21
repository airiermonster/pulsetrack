import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/index.dart';

class ExportService {
  Future<String?> exportToExcel(List<BloodPressureReading> readings, UserProfile? userProfile) async {
    try {
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Set headers
      sheet.getRangeByName('A1').setText('Date');
      sheet.getRangeByName('B1').setText('Time');
      sheet.getRangeByName('C1').setText('Systolic (mmHg)');
      sheet.getRangeByName('D1').setText('Diastolic (mmHg)');
      sheet.getRangeByName('E1').setText('Pulse (bpm)');
      sheet.getRangeByName('F1').setText('Time of Day');
      sheet.getRangeByName('G1').setText('Medication Status');
      sheet.getRangeByName('H1').setText('Category');
      sheet.getRangeByName('I1').setText('Notes');

      // Style headers
      final headerStyle = workbook.styles.add('HeaderStyle');
      headerStyle.fontName = 'Arial';
      headerStyle.fontSize = 12;
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.backColor = '#4472C4';
      headerStyle.bold = true;

      sheet.getRangeByName('A1:I1').cellStyle = headerStyle;

      // Add data
      for (int i = 0; i < readings.length; i++) {
        final reading = readings[i];
        final rowIndex = i + 2;

        sheet.getRangeByName('A$rowIndex').setText(reading.formattedDate);
        sheet.getRangeByName('B$rowIndex').setText(reading.formattedTime);
        sheet.getRangeByName('C$rowIndex').setNumber(reading.systolic.toDouble());
        sheet.getRangeByName('D$rowIndex').setNumber(reading.diastolic.toDouble());
        sheet.getRangeByName('E$rowIndex').setNumber(reading.pulse.toDouble());
        sheet.getRangeByName('F$rowIndex').setText(reading.dayTime.toString().split('.').last);
        sheet.getRangeByName('G$rowIndex').setText(reading.medicationStatus.toString().split('.').last);
        sheet.getRangeByName('H$rowIndex').setText(reading.category);
        sheet.getRangeByName('I$rowIndex').setText(reading.notes ?? '');
      }

      // Add summary statistics
      final summaryRow = readings.length + 4;
      sheet.getRangeByName('A$summaryRow').setText('Summary Statistics');
      sheet.getRangeByName('A${summaryRow + 1}').setText('Average Systolic:');
      sheet.getRangeByName('A${summaryRow + 2}').setText('Average Diastolic:');
      sheet.getRangeByName('A${summaryRow + 3}').setText('Average Pulse:');
      sheet.getRangeByName('A${summaryRow + 4}').setText('Total Readings:');

      if (readings.isNotEmpty) {
        final avgSystolic = readings.map((r) => r.systolic).reduce((a, b) => a + b) / readings.length;
        final avgDiastolic = readings.map((r) => r.diastolic).reduce((a, b) => a + b) / readings.length;
        final avgPulse = readings.map((r) => r.pulse).reduce((a, b) => a + b) / readings.length;

        sheet.getRangeByName('B${summaryRow + 1}').setNumber(avgSystolic);
        sheet.getRangeByName('B${summaryRow + 2}').setNumber(avgDiastolic);
        sheet.getRangeByName('B${summaryRow + 3}').setNumber(avgPulse);
        sheet.getRangeByName('B${summaryRow + 4}').setNumber(readings.length.toDouble());
      }

      // Auto-fit columns
      sheet.getRangeByName('A1:I${readings.length + summaryRow + 4}').autoFit();

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'blood_pressure_readings_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final path = '${directory.path}/$fileName';

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final file = File(path);
      await file.writeAsBytes(bytes);

      return path;
    } catch (e) {
      // Error exporting to Excel: $e
      return null;
    }
  }

}
