import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // Thêm để catch lỗi DioException HTTP 409

class StockAdjustmentController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();

  final RxList<AdjustmentItemRx> allItems = <AdjustmentItemRx>[].obs;
  final RxList<AdjustmentItemRx> filteredItems = <AdjustmentItemRx>[].obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController additionalNoteController =
      TextEditingController();

  @override
  void onReady() {
    super.onReady();
    _fetchInventoryToAdjust();
  }

  Future<void> _fetchInventoryToAdjust() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);
      final data = await _provider.getInventoriesForAdjustment();

      final parsedItems = data.map((e) {
        final packageJson = e['productPackage'];
        final packageInfo = packageJson != null
            ? ProductPackageModel.fromJson(packageJson)
            : null;

        return AdjustmentItemRx(
          id: e['id'] ?? '',
          packageId: e['productPackageId'] ?? '',
          name: packageInfo?.displayName ?? TTexts.unknownProduct.tr,
          initialSystemQty: e['quantity'] ?? 0,
          packageInfo: packageInfo,
        );
      }).toList();

      allItems.assignAll(parsedItems);
      filteredItems.assignAll(parsedItems);
      FullScreenLoaderUtils.stopLoading();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  void filterItems(String query) {
    if (query.trim().isEmpty) {
      filteredItems.assignAll(allItems);
    } else {
      final keyword = query.trim().toLowerCase();
      filteredItems.assignAll(
        allItems
            .where((item) => item.name.toLowerCase().contains(keyword))
            .toList(),
      );
    }
  }

  int get totalItems => allItems.length;
  int get checkedItemsCount =>
      allItems.where((item) => item.isChecked.value).length;
  bool get canSave => checkedItemsCount > 0;

  // 🟢 GỘP TẤT CẢ CÁC NOTE LẺ TẺ THÀNH 1 LIST CHUỖI
  String get combinedItemNotes {
    List<String> notes = [];
    for (var item in allItems) {
      if (item.isChecked.value && item.note.value.trim().isNotEmpty) {
        notes.add("• ${item.note.value.trim()}");
      }
    }
    return notes.join("\n");
  }

  void goToItemAdjustmentPage(AdjustmentItemRx item) {
    Get.toNamed(AppRoutes.stockAdjustmentItem, arguments: item);
  }

  // 🟢 NÚT FAB: CHECK ALL (Chỉ Check những món chưa làm)
  void checkAllUncheckedItems() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmCheckAllTitle.tr,
        description: TTexts.confirmCheckAllDesc.tr,
        icon: const Text('✅', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirm.tr,
        onPrimaryPressed: () {
          Get.back();
          for (var item in allItems) {
            if (!item.isChecked.value) {
              item.isChecked.value = true;
              item.actualQty.value = item.systemQty.value; // Không bị lệch
              item.selectedReason.value = '';
              item.note.value = '';
            }
          }
          filteredItems.refresh();
        },
        secondaryButtonText: TTexts.cancel.tr,
      ),
    );
  }

  // 🟢 NÚT FAB: UNCHECK ALL (Reset lại toàn bộ thẻ)
  void uncheckAllItems() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmUncheckAllTitle.tr,
        description: TTexts.confirmUncheckAllDesc.tr,
        icon: const Text('⚠️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirm.tr,
        onPrimaryPressed: () {
          Get.back();
          for (var item in allItems) {
            item.isChecked.value = false;
            item.actualQty.value = item.systemQty.value;
            item.selectedReason.value = '';
            item.note.value = '';
          }
          filteredItems.refresh();
        },
        secondaryButtonText: TTexts.cancel.tr,
      ),
    );
  }

  // 🟢 BẪY LỖI THOÁT TRANG KHI ĐANG KIỂM KHO GIANG DỞ
  void handleExit() {
    if (checkedItemsCount > 0) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.unsavedChangesTitle.tr,
          description: TTexts.unsavedChangesDesc.tr,
          icon: const Text('🚨', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.exitAnyway.tr,
          onPrimaryPressed: () {
            Get.back(); // Đóng Dialog
            Get.back(); // Đóng trang Stock Adjustment
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    } else {
      Get.back();
    }
  }

  // 🟢 GOM CHUNG LẠI: CHỈ XÁC NHẬN VÀ BẮN API
  void handleSaveAdjustment() {
    if (!canSave) return;

    if (checkedItemsCount < totalItems) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.incompleteSaveTitle.tr,
          description: TTexts.incompleteSaveDesc.tr,
          icon: const Text('👀', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.proceedAdjustment.tr,
          onPrimaryPressed: () {
            Get.back();
            executeSave();
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    } else {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.confirmSaveTitle.tr,
          description: TTexts.confirmSaveDesc.tr,
          icon: const Text('💾', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.confirm.tr,
          onPrimaryPressed: () {
            Get.back();
            executeSave();
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    }
  }

  // 🟢 EXECUTE SAVE: CHUYỂN GIAO TOÀN BỘ LOGIC CHO BACKEND
  Future<void> executeSave() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final itemsToUpdate = allItems.where((i) => i.isChecked.value).toList();

      // 1. Xây dựng Ghi chú
      String globalNote = combinedItemNotes;
      final addNote = additionalNoteController.text.trim();
      if (addNote.isNotEmpty) {
        if (globalNote.isNotEmpty) globalNote += "\n\n";
        globalNote += "${TTexts.additionalNote.tr}\n$addNote";
      }
      if (globalNote.isEmpty) {
        globalNote = TTexts.defaultAdjustmentNote.tr;
      }

      // 2. Xây dựng Payload
      double totalAdjustmentValue = 0.0;
      List<Map<String, dynamic>> itemsPayload = [];

      // 🟢 TẠO LIST TRANSACTION DETAIL MODEL ĐỂ TRUYỀN SANG TRANG SUMMARY
      List<TransactionDetailModel> summaryDetails = [];

      for (var item in itemsToUpdate) {
        double unitPrice = item.packageInfo?.importPrice ?? 0.0;
        totalAdjustmentValue += (item.spread * unitPrice);

        itemsPayload.add({
          "productPackageId": item.packageId,
          "systemQty": item.systemQty.value,
          "actualQty": item.actualQty.value,
          "unitPrice": unitPrice,
          "reason": item.selectedReason.value.tr,
          "note": item.note.value,
        });

        // Add vào model summary
        summaryDetails.add(TransactionDetailModel(
          productPackageId: item.packageId,
          quantity: item.spread, // Chỉ lấy độ lệch
          unitPrice: unitPrice,
          packageInfo: item.packageInfo,
        ));
      }

      // ignore: unused_local_variable
      final payload = {
        "type": "ADJUSTMENT",
        "status": "COMPLETED",
        "totalPrice": totalAdjustmentValue,
        "note": globalNote,
        "items": itemsPayload
      };

      // =========================================================================
      // 🚧 TODO (BACKEND INTEGRATION - CƠ CHẾ KIỂM TRA ĐỤNG ĐỘ DỮ LIỆU):
      // Frontend sẽ chỉ gọi 1 API duy nhất (VD: POST /api/transactions/adjustments).
      // Backend BẮT BUỘC phải thực hiện luồng sau bằng DB Transaction (All or Nothing):
      //
      // 1. Nhận mảng `items` có chứa `systemQty` (số lượng tồn kho lúc Frontend đang đếm).
      // 2. Query lại số lượng tồn kho mới nhất trong Database của từng `productPackageId`.
      // 3. SO SÁNH: Nếu `systemQty` frontend gửi KHÁC với số lượng trong DB:
      //    -> Chứng tỏ trong lúc NV A đếm kho, NV B đã xuất/nhập làm đổi số liệu.
      //    -> Lập tức Rollback Transaction! Trả về lỗi HTTP 409 Conflict.
      //    -> Format lỗi trả về phải chứa mảng `conflicts`: [{productPackageId, newSystemQty}].
      // 4. NẾU KHỚP (An toàn): Tạo Transaction, Tạo TransactionDetail, Update Quantity/LastCount cho Inventory.
      // =========================================================================

      // MÔ PHỎNG CALL API: await _provider.createAdjustmentTransaction(payload);
      await Future.delayed(const Duration(seconds: 1));

      // 🟢 TẠO TRANSACTION MODEL ĐỂ ĐIỀU HƯỚNG SANG SUMMARY
      final summaryTransaction = TransactionModel(
        transactionId:
            "ADJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}", // Fake ID tạm
        createdAt: DateTime.now(),
        type: 'ADJUSTMENT',
        status: 'COMPLETED',
        totalPrice: totalAdjustmentValue,
        note: globalNote,
        items: summaryDetails,
      );

      FullScreenLoaderUtils.stopLoading();

      Get.offNamed(AppRoutes.transactionSummary, arguments: summaryTransaction);

      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.inventoryUpdatedSuccess.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      // 🟢 BẪY LỖI 409 CONFLICT TỪ BACKEND TRẢ VỀ
      if (e is DioException && e.response?.statusCode == 409) {
        final List<dynamic> conflicts = e.response?.data['conflicts'] ?? [];
        List<String> conflictedNames = [];

        for (var conflict in conflicts) {
          final String pkgId = conflict['productPackageId'];
          final int newSystemQty =
              conflict['newSystemQty']; // Lấy số System mới nhất Backend trả về

          final index = allItems.indexWhere((i) => i.packageId == pkgId);
          if (index != -1) {
            final item = allItems[index];
            conflictedNames.add(item.name);

            // Cập nhật lại số liệu hệ thống & Uncheck thẻ đó để ép kiểm lại
            item.systemQty.value = newSystemQty;
            item.isChecked.value = false;
          }
        }

        filteredItems.refresh();
        Get.dialog(
          TCustomDialogWidget(
            title: TTexts.syncDataWarningTitle.tr,
            description:
                "${TTexts.syncDataWarningDesc.tr}\n\n${conflictedNames.map((e) => "• $e").join("\n")}",
            icon: const Text('🔄', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.confirm.tr,
            onPrimaryPressed: () => Get.back(),
          ),
        );
      } else {
        handleError(e); // Quăng vào Error Handler chuẩn nếu không phải 409
      }
    }
  }

  void openScanner() {}

  @override
  void onClose() {
    searchController.dispose();
    additionalNoteController.dispose();
    super.onClose();
  }
}
