import 'dart:io';
import 'package:excel/excel.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportTransactionExportController extends GetxController {
  final RxBool isExporting = false.obs;

  final RxDouble exportProgress = 0.0.obs;
  final RxString exportStatus = ''.obs;

  Future<void> exportTransactionToExcel(TransactionModel tx) async {
    try {
      isExporting.value = true;
      exportProgress.value = 0.0;
      exportStatus.value = 'Preparing to export...';

      // 1. Xin quyền (Tiến độ 10%)
      exportProgress.value = 0.1;
      exportStatus.value = 'Checking permissions...';
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }
      await Future.delayed(
          const Duration(milliseconds: 300)); // Delay tạo độ mượt UI

      // 2. Khởi tạo Excel (Tiến độ 30%)
      exportProgress.value = 0.3;
      exportStatus.value = 'Creating document...';
      var excel = Excel.createExcel();
      String rawId = tx.transactionId ?? 'Tx';
      String shortId = rawId.length > 15 ? rawId.substring(0, 15) : rawId;
      String sheetName = 'Receipt_$shortId';

      Sheet sheetObject = excel[sheetName];
      excel.setDefaultSheet(sheetName);
      CellStyle boldStyle = CellStyle(bold: true);

      // 3. Đổ dữ liệu Header (Tiến độ 50%)
      exportProgress.value = 0.5;
      exportStatus.value = 'Writing transaction info...';
      final dateFormatted =
          DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt ?? DateTime.now());

      sheetObject.appendRow([TextCellValue('TRANSACTION RECEIPT')]);
      sheetObject.appendRow([
        TextCellValue('Transaction ID:'),
        TextCellValue(tx.transactionId ?? 'N/A')
      ]);
      sheetObject.appendRow([TextCellValue('Type:'), TextCellValue(tx.type)]);
      sheetObject
          .appendRow([TextCellValue('Status:'), TextCellValue(tx.status)]);
      sheetObject
          .appendRow([TextCellValue('Date:'), TextCellValue(dateFormatted)]);
      sheetObject.appendRow(
          [TextCellValue('Total Amount:'), DoubleCellValue(tx.totalPrice)]);
      sheetObject.appendRow([TextCellValue('')]);

      sheetObject.appendRow([
        TextCellValue('No.'),
        TextCellValue('Product Name'),
        TextCellValue('Barcode'),
        TextCellValue('Unit Price (\$)'),
        TextCellValue('Quantity'),
        TextCellValue('Total (\$)'),
      ]);

      for (int i = 0; i < 6; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 7))
            .cellStyle = boldStyle;
      }
      await Future.delayed(const Duration(milliseconds: 400));

      // 4. Đổ dữ liệu Items (Tiến độ 70%)
      exportProgress.value = 0.7;
      exportStatus.value = 'Processing items...';
      for (int i = 0; i < tx.items.length; i++) {
        final item = tx.items[i];
        final productName = item.packageInfo?.displayName ?? 'Unknown Product';
        final barcode = item.packageInfo?.barcodeValue ?? 'N/A';
        final itemTotal = item.unitPrice * item.quantity;

        sheetObject.appendRow([
          IntCellValue(i + 1),
          TextCellValue(productName),
          TextCellValue(barcode),
          DoubleCellValue(item.unitPrice),
          IntCellValue(item.quantity),
          DoubleCellValue(itemTotal),
        ]);
      }
      await Future.delayed(const Duration(milliseconds: 300));

      // 5. Lưu File (Tiến độ 90% -> 100%)
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
      await Future.delayed(const Duration(
          milliseconds: 400)); // Dừng lại 1 xíu cho user thấy 100%

      // Đóng Bottom Sheet
      if (Get.isBottomSheetOpen == true) Get.back();

      // 6. Snackbar thành công
      TSnackbarsWidget.success(
        title: 'Export Successful',
        message: 'File saved to Downloads folder.',
        actionText: 'OPEN', // Truyền text cho nút Action
        onActionPressed: () async {
          final result = await OpenFile.open(filePath);

          // Xử lý lỗi không có app đọc Excel
          if (result.type != ResultType.done) {
            // TSnackbarsWidget dùng ScaffoldMessenger nên tự nó ghi đè/tắt cái cũ nếu được cấu hình tốt
            TSnackbarsWidget.error(
              title: 'Cannot open file',
              message:
                  'No app found to read Excel (.xlsx) files. Please install Microsoft Excel or Google Sheets on your device.',
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
