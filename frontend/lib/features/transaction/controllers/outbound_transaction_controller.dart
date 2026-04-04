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
import 'package:get/get.dart';

class OutboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();
  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;

  final TextEditingController noteController = TextEditingController();

  // BIẾN TÀI CHÍNH MỚI (1: Cộng tiền, 0: Không thu tiền, -1: Trừ tiền)
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

  // Xác định hệ số nhân dựa trên lý do
  double get amountMultiplier {
    if (selectedReason.value == TTexts.reasonDamaged) {
      return 0.0; // Hủy hàng -> Doanh thu = 0
    }
    if (selectedReason.value == TTexts.reasonOther) {
      return otherFinancialEffect.value
          .toDouble(); // Trả về 1.0, 0.0, hoặc -1.0
    }
    return 1.0; // Sale, Return -> Doanh thu dương (+)
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

  // 🟢 LOGIC TỰ ĐỘNG HỎI XÓA KHI BẤM VỀ 0
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
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)), // Emoji chuẩn
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

  // 🟢 1. KIỂM TRA THAY ĐỔI GIÁ (SELLING PRICE) - ĐỒNG BỘ VỚI INBOUND
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
          title: TTexts.priceChangeDetected.tr, // Tiêu đề chung
          description: TTexts
              .priceChangeMessage.tr, // Hỏi có muốn update giá master không
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
            _showConfirmExportDialog(
                updatePrice: true); // Xác nhận & update giá
          },
          secondaryButtonText: TTexts.justCreateTransaction.tr,
          onSecondaryPressed: () {
            Get.back();
            _showConfirmExportDialog(
                updatePrice: false); // Chỉ xuất kho, không update
          },
        ),
      );
    } else {
      _showConfirmExportDialog(updatePrice: false);
    }
  }

  // 🟢 2. XÁC NHẬN XUẤT KHO CHÍNH THỨC
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

  // 🟢 3. THỰC THI API (CÓ XỬ LÝ UPDATE SELLING PRICE)
  Future<void> completeExport({required bool updatePrice}) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.processingExport.tr);

      // Gắn hậu tố hiệu ứng tài chính vào Note nếu chọn Other
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

      await _provider.createTransaction(transaction);

      // 🟢 NẾU NGƯỜI DÙNG CHỌN CẬP NHẬT GIÁ BÁN -> BẮN API UPDATE
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

      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.exportSuccessMessage.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
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
