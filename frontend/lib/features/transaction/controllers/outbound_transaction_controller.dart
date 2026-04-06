import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // 🟢 Bổ sung Dio để bắt lỗi HTTP

class OutboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;

  final TextEditingController noteController = TextEditingController();

  // BIẾN TÀI CHÍNH
  final RxString selectedReason = TTexts.reasonRetailSale.obs;
  final RxInt otherFinancialEffect = 1.obs;

  final List<String> predefinedReasons = [
    TTexts.reasonRetailSale,
    TTexts.reasonReturn,
    TTexts.reasonDamaged,
    TTexts.reasonOther,
  ];

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get rawTotalAmount =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  double get amountMultiplier {
    if (selectedReason.value == TTexts.reasonDamaged) return 0.0;
    if (selectedReason.value == TTexts.reasonOther) {
      return otherFinancialEffect.value.toDouble();
    }
    return 1.0;
  }

  double get totalAmount => rawTotalAmount * amountMultiplier;

  void selectReason(String reasonKey) {
    selectedReason.value = reasonKey;
  }

  void addToCart(Map<String, dynamic> productData,
      {int quantity = 1, double? customPrice}) {
    final String? pkgId = productData['productPackageId'];
    if (pkgId == null || pkgId.isEmpty) return;

    final index =
        cartItems.indexWhere((item) => item.productPackageId == pkgId);
    if (index != -1) {
      final currentItem = cartItems[index];
      cartItems[index] = TransactionDetailModel(
        productPackageId: pkgId,
        quantity: quantity,
        unitPrice: customPrice ?? currentItem.unitPrice,
        packageInfo: productData['packageInfo'] ?? currentItem.packageInfo,
        currentStock: currentItem.currentStock,
        reorderThreshold: currentItem.reorderThreshold,
      );
    } else {
      cartItems.add(TransactionDetailModel(
        productPackageId: pkgId,
        quantity: quantity,
        unitPrice: customPrice ?? productData['sellingPrice'] ?? 0.0,
        packageInfo: productData['packageInfo'],
        currentStock: productData['currentStock'] ?? 0,
        reorderThreshold: productData['reorderThreshold'] ?? 0,
      ));
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
    } else {
      final item = cartItems[index];
      cartItems[index] = TransactionDetailModel(
        productPackageId: item.productPackageId,
        quantity: newQuantity,
        unitPrice: item.unitPrice,
        packageInfo: item.packageInfo,
        currentStock: item.currentStock,
        reorderThreshold: item.reorderThreshold,
      );
    }
  }

  void removeItem(int index) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.removeItem.tr,
        description: TTexts.confirmRemoveItemTransaction.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.remove.tr,
        onPrimaryPressed: () {
          cartItems.removeAt(index);
          Get.back();
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  // 🟢 1. BẪY LỖI THOÁT TRANG
  void handleExit() {
    if (cartItems.isNotEmpty) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.discardTransactionTitle.tr,
          description: TTexts.discardTransactionDesc.tr,
          icon: const Text('🚨', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.exitAnyway.tr,
          onPrimaryPressed: () {
            Get.back();
            Get.back();
          },
          secondaryButtonText: TTexts.cancel.tr,
        ),
      );
    } else {
      Get.back();
    }
  }

  Future<void> handleExportWithPriceCheck() async {
    if (cartItems.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.emptyCartWarning.tr);
      return;
    }

    final changedPriceItems = cartItems.where((item) {
      final originalPrice = item.packageInfo?.sellingPrice ?? 0.0;
      return (item.unitPrice - originalPrice).abs() > 0.01;
    }).toList();

    if (changedPriceItems.isNotEmpty) {
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.priceChangeDetected.tr,
          description: TTexts.priceChangeMessage.tr,
          icon: const Text('💵', style: TextStyle(fontSize: 40)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: changedPriceItems.map((item) {
              final original = item.packageInfo?.sellingPrice ?? 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${item.packageInfo?.displayName}: \$${original.toStringAsFixed(2)} ➔ \$${item.unitPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.primaryText),
                ),
              );
            }).toList(),
          ),
          primaryButtonText: TTexts.updatePricesAndCreate.tr,
          onPrimaryPressed: () {
            Get.back();
            _showConfirmExportDialog(updatePrice: true);
          },
          secondaryButtonText: TTexts.justCreateTransaction.tr,
          onSecondaryPressed: () {
            Get.back();
            _showConfirmExportDialog(updatePrice: false);
          },
        ),
      );
    } else {
      _showConfirmExportDialog(updatePrice: false);
    }
  }

  void _showConfirmExportDialog({required bool updatePrice}) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmExportTitle.tr,
        description: TTexts.confirmExportDescription.tr,
        icon: const Text('👍', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.proceedExport.tr,
        onPrimaryPressed: () {
          Get.back();
          completeExport(updatePrice: updatePrice);
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  // 🟢 THỰC THI API CÓ BẪY LỖI CONCURRENCY (HẾT HÀNG ĐỘT NGỘT)
  Future<void> completeExport({required bool updatePrice}) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.processingExport.tr);

      String effectStr = "";
      if (selectedReason.value == TTexts.reasonOther) {
        if (otherFinancialEffect.value == 1) effectStr = " (+)";
        if (otherFinancialEffect.value == 0) effectStr = " (0)";
        if (otherFinancialEffect.value == -1) effectStr = " (-)";
      }

      final prefixReason = "[${selectedReason.value.tr}$effectStr]";
      final finalNote = noteController.text.trim().isNotEmpty
          ? "$prefixReason ${noteController.text.trim()}"
          : prefixReason;

      final transaction = TransactionModel(
        totalPrice: totalAmount,
        type: 'OUTBOUND',
        status: 'COMPLETED',
        note: finalNote,
        items: cartItems.toList(),
      );

      // =========================================================================
      // 🚧 TODO (BACKEND INTEGRATION - OUTBOUND CONCURRENCY CHECK):
      // Khi Frontend gọi API tạo Transaction (Outbound / Bán hàng):
      // 1. Backend BẮT BUỘC dùng Database Transaction để khóa các row liên quan.
      // 2. Loop qua mảng `items` gửi lên, query `quantity` hiện tại trong bảng `Inventory`.
      // 3. SO SÁNH: Nếu `inventory.quantity < item.quantity` (Số lượng tồn < Số lượng muốn xuất):
      //    -> Lập tức ROLLBACK Transaction!
      //    -> Trả về mã lỗi HTTP 409 Conflict.
      //    -> Payload lỗi: { "conflicts": [ { "productPackageId": "uuid", "currentStock": 0, "requested": 2 } ] }
      // 4. Nếu đủ hàng -> Tiến hành trừ kho và lưu Transaction như bình thường.
      // =========================================================================

      await _provider.createTransaction(transaction);

      if (updatePrice) {
        final validItems = cartItems.where((item) =>
            item.productPackageId != null && item.productPackageId!.isNotEmpty);

        List<Future<void>> updateTasks = [];
        for (var item in validItems) {
          updateTasks.add(_provider.updateProductPackage(
              item.productPackageId!, {'sellingPrice': item.unitPrice}));
        }

        if (updateTasks.isNotEmpty) {
          await Future.wait(updateTasks);
        }
      }

      FullScreenLoaderUtils.stopLoading();

      cartItems.clear();
      noteController.clear();
      selectedReason.value = TTexts.reasonRetailSale;

      Get.offNamed(AppRoutes.transactionSummary, arguments: transaction);

      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.exportSuccessMessage.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      if (e is DioException && e.response?.statusCode == 409) {
        final List<dynamic> conflicts = e.response?.data['conflicts'] ?? [];
        List<String> conflictedNames = [];

        for (var conflict in conflicts) {
          final String pkgId = conflict['productPackageId'];
          final int newStock = conflict['currentStock'] ?? 0;

          final index =
              cartItems.indexWhere((i) => i.productPackageId == pkgId);
          if (index != -1) {
            final item = cartItems[index];
            final productName =
                item.packageInfo?.displayName ?? TTexts.unknownProduct.tr;

            final stockText = "${TTexts.actualStock.tr}: $newStock";
            final actionText = TTexts.autoRemovedFromCart.tr;

            conflictedNames.add("$productName ($stockText) ➔ $actionText");

            cartItems.removeAt(index);
          }
        }

        Get.dialog(
          TCustomDialogWidget(
            title: TTexts.outOfStockTitle.tr,
            description:
                "${TTexts.outOfStockDesc.tr}\n\n${TTexts.updatedListLabel.tr}\n${conflictedNames.map((e) => "• $e").join("\n")}",
            icon: const Text('🛒', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.confirm.tr,
            onPrimaryPressed: () => Get.back(),
          ),
        );
      } else {
        handleError(e);
      }
    }
  }

  void openScanner() {
    Get.to(() => TBarcodeScannerLayout(
          title: TTexts.scanProductBarcode.tr,
          onScanned: (code) => Get.back(),
        ));
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
