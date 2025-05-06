import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';

class TextActionService {
  // Save text as PDF
  Future<void> saveText(BuildContext context, String? text) async {
    if (text != null && text.isNotEmpty) {
      try {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getDownloadsDirectory() ??
              await getApplicationDocumentsDirectory();
        }

        if (!await directory!.exists()) {
          await directory.create(recursive: true);
        }

        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final filePath = '${directory.path}/Scan_Result_$timestamp.pdf';

        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(
                text,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ),
        );

        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        print('PDF saved to: $filePath');

        CustomSnackBar.show(
          context,
          message: 'PDF saved to $filePath',
          type: SnackBarType.success,
        );
      } catch (e) {
        print('Error saving PDF: $e');
        CustomSnackBar.show(
          context,
          message: 'Error saving PDF: $e',
          type: SnackBarType.error,
        );
      }
    } else {
      CustomSnackBar.show(
        context,
        message: 'No text to save!',
        type: SnackBarType.error,
      );
    }
  }
}
