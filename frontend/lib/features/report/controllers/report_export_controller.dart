import 'dart:io';
import 'package:excel/excel.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportExportController extends GetxController {
  final RxBool isExporting = false.obs;
  final RxDouble exportProgress = 0.0.obs;
  final RxString exportStatus = ''.obs;

  Future<void> exportDailyTransactions(
      List<TransactionModel> transactions, String dateStr) async {
    if (transactions.isEmpty) {
      if (Get.isBottomSheetOpen == true) Get.back();
      TSnackbarsWidget.error(
          title: 'Export Failed',
          message: 'No transactions to export for this date.');
      if (Get.isBottomSheetOpen == true) Get.back();
      return;
    }

    try {
      isExporting.value = true;
      exportProgress.value = 0.1;
      exportStatus.value = 'Checking permissions...';

      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) await Permission.storage.request();
      }
      await Future.delayed(const Duration(milliseconds: 300));

      exportProgress.value = 0.3;
      exportStatus.value = 'Creating document...';
      var excel = Excel.createExcel();

      String safeDate = dateStr.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String sheetName = 'Report_$safeDate';
      if (sheetName.length > 31) {
        sheetName = sheetName.substring(0, 31);
      }

      Sheet sheetObject = excel[sheetName];
      excel.setDefaultSheet(sheetName);
      CellStyle boldStyle = CellStyle(bold: true);

      exportProgress.value = 0.5;
      exportStatus.value = 'Writing summary...';

      sheetObject.appendRow([TextCellValue('DAILY TRANSACTION REPORT')]);
      sheetObject.appendRow([TextCellValue('Date:'), TextCellValue(dateStr)]);
      sheetObject.appendRow([
        TextCellValue('Total Transactions:'),
        IntCellValue(transactions.length)
      ]);
      sheetObject.appendRow([TextCellValue('')]);

      // Header Bảng
      sheetObject.appendRow([
        TextCellValue('No.'),
        TextCellValue('Transaction ID'),
        TextCellValue('Time'),
        TextCellValue('Type'),
        TextCellValue('Status'),
        TextCellValue('Total Items'),
        TextCellValue('Total Amount (\$)'),
      ]);

      for (int i = 0; i < 7; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4))
            .cellStyle = boldStyle;
      }

      exportProgress.value = 0.7;
      exportStatus.value = 'Processing transactions...';

      double grandTotalAmount = 0.0;
      int grandTotalItems = 0;

      for (int i = 0; i < transactions.length; i++) {
        final tx = transactions[i];
        final timeStr =
            DateFormat('HH:mm').format(tx.createdAt ?? DateTime.now());
        final totalItems = tx.items.fold(0, (sum, item) => sum + item.quantity);

        grandTotalItems += totalItems;
        if (tx.status != 'CANCELLED') grandTotalAmount += tx.totalPrice;

        sheetObject.appendRow([
          IntCellValue(i + 1),
          TextCellValue(tx.transactionId ?? 'N/A'),
          TextCellValue(timeStr),
          TextCellValue(tx.type),
          TextCellValue(tx.status),
          IntCellValue(totalItems),
          DoubleCellValue(tx.totalPrice),
        ]);
      }

      // Dòng Tổng Cộng Cuối Bảng
      sheetObject.appendRow([TextCellValue('')]);
      sheetObject.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('GRAND TOTAL:'),
        IntCellValue(grandTotalItems),
        DoubleCellValue(grandTotalAmount),
      ]);

      for (int i = 4; i < 7; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: i, rowIndex: transactions.length + 6))
            .cellStyle = boldStyle;
      }

      exportProgress.value = 0.9;
      exportStatus.value = 'Saving file...';

      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception("Failed to generate Excel file");

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String filePath = '${directory!.path}/$sheetName.xlsx';
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      exportProgress.value = 1.0;
      exportStatus.value = 'Export Complete!';
      await Future.delayed(const Duration(milliseconds: 400));

      if (Get.isBottomSheetOpen == true) Get.back();

      TSnackbarsWidget.success(
        title: 'Report Exported',
        message: 'File saved to Downloads folder.',
        actionText: 'OPEN',
        onActionPressed: () async {
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            TSnackbarsWidget.error(
              title: 'Cannot open file',
              message: 'No app found to read Excel (.xlsx) files.',
            );
          }
        },
      );
    } catch (e) {
      if (Get.isBottomSheetOpen == true) Get.back();
      TSnackbarsWidget.error(title: 'Export Failed', message: e.toString());
    } finally {
      isExporting.value = false;
    }
  }
}
