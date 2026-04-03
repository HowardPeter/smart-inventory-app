import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class InboundTransactionController extends GetxController with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();

  final RxList<TransactionDetailModel> cartItems =
      <TransactionDetailModel>[].obs;
  final RxList<Map<String, dynamic>> suggestedProducts =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingSuggestions = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSuggestedProducts();
  }

  double get totalFunds =>
      cartItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

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

    if (index != -1) {
      final currentItem = cartItems[index];
      cartItems[index] = TransactionDetailModel(
        productPackageId: pkgId,
        quantity: currentItem.quantity + quantity,
        unitPrice: customPrice ?? currentItem.unitPrice,
        packageInfo: productData['packageInfo'] ?? currentItem.packageInfo,
        currentStock: currentItem.currentStock,
        reorderThreshold: currentItem.reorderThreshold,
      );
    } else {
      cartItems.add(TransactionDetailModel(
        productPackageId: pkgId,
        quantity: quantity,
        unitPrice: customPrice ?? productData['importPrice'],
        packageInfo: productData['packageInfo'],
        currentStock: productData['currentStock'],
        reorderThreshold: productData['reorderThreshold'],
      ));
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
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

  Future<void> fetchSuggestedProducts() async {
    isLoadingSuggestions.value = true;
    try {
      final data = await _provider.getSuggestedPackagesForInbound();
      suggestedProducts.assignAll(data);
    } catch (e) {
      handleError(e);
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  Future<void> completeImport() async {
    if (cartItems.isEmpty) return;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.creatingImportTicket.tr);

      // 1. Tạo Transaction (HIỆN TẠI ĐANG FAKE)
      final transaction = TransactionModel(
        totalPrice: totalFunds,
        type: 'INBOUND',
        status: 'COMPLETED',
        note: TTexts.manualImport.tr,
        items: cartItems.toList(),
      );
      await _provider.createTransaction(transaction);

      // =========================================================================
      // 🚧 TODO (BACKEND INTEGRATION):
      // Khi Backend làm xong API Transaction (VD: POST /api/transactions),
      // hãy xóa vòng lặp phía dưới đi. Frontend chỉ việc gọi đúng 1 API tạo Transaction.
      // Backend sẽ dùng CƠ CHẾ DATABASE TRANSACTION ($transaction trong Prisma) để:
      //  - 1. Tạo bản ghi Transaction & Transaction Details.
      //  - 2. Tự động UPDATE `importPrice` của ProductPackage.
      //  - 3. Tự động INCREASE `quantity` trong bảng Inventory.
      // Việc này đảm bảo tính nhất quán (All or Nothing), Frontend không nên tự gọi 3 API.
      // =========================================================================

      // Lấy danh sách item hợp lệ
      final validItems = cartItems.where((item) =>
          item.productPackageId != null && item.productPackageId!.isNotEmpty);

      // Mảng chứa các request song song
      List<Future<void>> updateTasks = [];

      for (var item in validItems) {
        final pkgId = item.productPackageId!;

        // A. CẬP NHẬT INVENTORY (Tăng số lượng kho thực tế)
        updateTasks.add(_provider.adjustInventory(
          pkgId,
          type: 'increase',
          quantity: item.quantity,
          note: TTexts.manualImport.tr,
        ));

        // B. CẬP NHẬT PRODUCT PACKAGE (Cập nhật lại giá nhập - importPrice)
        // item.unitPrice chính là giá tiền người dùng đã nhập ở ô Import Price
        updateTasks.add(_provider
            .updateProductPackage(pkgId, {'importPrice': item.unitPrice}));
      }

      // Đẩy tất cả các API đi cùng một lúc (Chờ tất cả hoàn thành)
      await Future.wait(updateTasks);

      FullScreenLoaderUtils.stopLoading();

      // Xóa giỏ hàng và thoát
      cartItems.clear();
      Get.back();
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.importTicketCreated.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.errorCreatingImportTicket.tr);
    }
  }

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
}
