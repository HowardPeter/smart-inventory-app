import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class OutboundTransactionController extends GetxController with TErrorHandler {
  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;

  double get totalAmount =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  // 🟢 THÊM HÀNG VÀO GIỎ TỪ TRANG TÌM KIẾM
  void addToCart(Map<String, dynamic> productData,
      {int quantity = 1, double? customPrice}) {
    final String? pkgId = productData['productPackageId'];

    if (pkgId == null || pkgId.isEmpty || pkgId == "null") {
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: TTexts.errorNoPackageId.tr);
      return;
    }

    final index =
        cartItems.indexWhere((item) => item.productPackageId == pkgId);
    final int currentStock = productData['currentStock'] ?? 0;

    if (index != -1) {
      final currentItem = cartItems[index];
      final newQty = currentItem.quantity + quantity;

      // Bẫy lỗi: Xuất kho không được vượt tồn kho
      if (newQty <= currentStock) {
        cartItems[index] = TransactionDetailModel(
          productPackageId: pkgId,
          quantity: newQty,
          unitPrice: customPrice ?? currentItem.unitPrice,
          packageInfo: productData['packageInfo'] ?? currentItem.packageInfo,
          currentStock: currentItem.currentStock,
          reorderThreshold: currentItem.reorderThreshold,
        );
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr, message: TTexts.outOfStockAlert.tr);
      }
    } else {
      if (quantity <= currentStock) {
        cartItems.add(TransactionDetailModel(
          productPackageId: pkgId,
          quantity: quantity,
          unitPrice: customPrice ??
              productData['sellingPrice'] ??
              0.0, // Xuất kho thì dùng giá Bán
          packageInfo: productData['packageInfo'],
          currentStock: currentStock,
          reorderThreshold: productData['reorderThreshold'] ?? 0,
        ));
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr, message: TTexts.outOfStockAlert.tr);
      }
    }
  }

  // 🟢 CẬP NHẬT TĂNG/GIẢM SỐ LƯỢNG TRONG GIỎ
  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      // Xác nhận xóa nếu số lượng về 0
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.removeItem.tr,
          description: TTexts.confirmRemoveItemTransaction.tr,
          icon: const Icon(Iconsax.trash_copy,
              color: AppColors.stockOut, size: 32),
          primaryButtonText: TTexts.remove.tr,
          onPrimaryPressed: () {
            cartItems.removeAt(index);
            Get.back();
          },
          secondaryButtonText: TTexts.cancel.tr,
          onSecondaryPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } else {
      final item = cartItems[index];
      // Bẫy lỗi: Không bấm tăng quá số tồn kho
      if (newQuantity <= item.currentStock) {
        cartItems[index] = TransactionDetailModel(
          productPackageId: item.productPackageId,
          quantity: newQuantity,
          unitPrice: item.unitPrice,
          packageInfo: item.packageInfo,
          currentStock: item.currentStock,
          reorderThreshold: item.reorderThreshold,
        );
      } else {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr, message: TTexts.outOfStockAlert.tr);
      }
    }
  }

  // 🟢 MỞ MÁY QUÉT MÃ VẠCH
  void openScanner() {
    Get.to(
      () => TBarcodeScannerLayout(
        title: TTexts.scanProductBarcode.tr,
        onScanned: (code) {
          TSnackbarsWidget.info(
              title: TTexts.info.tr, message: "Quét được mã: $code");
          Get.back();
        },
      ),
      transition: Transition.downToUp,
    );
  }

  // 🟢 ĐIỀU HƯỚNG TỚI BƯỚC CONFIRM KHI BẤM NÚT (Sẽ làm BottomSheet confirm sau)
  void goToSummary() {
    if (cartItems.isEmpty) return;
    // Tạm thời gọi snackbar, sau này sẽ thay bằng gọi hàm bật Bottom Sheet chọn Reason/Note
    TSnackbarsWidget.success(
        title: TTexts.successTitle.tr, message: "Proceed to checkout...");
  }
}
