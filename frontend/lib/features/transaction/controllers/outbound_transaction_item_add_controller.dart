import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/routes/app_routes.dart';

class OutboundTransactionItemAddController extends GetxController
    with TErrorHandler {
  final TransactionProvider _provider = TransactionProvider();

  late final InventoryInsightDisplayModel initialItem;
  final Rxn<InventoryModel> freshInventoryData = Rxn<InventoryModel>();
  final RxBool isLoadingFreshData = true.obs;

  final TextEditingController priceController = TextEditingController();
  final RxDouble totalPrice = 0.0.obs;

  final RxList<TransactionModel> availableInboundTxs = <TransactionModel>[].obs;
  final RxMap<String, int> selectedBatchesQty = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is InventoryInsightDisplayModel) {
      initialItem = Get.arguments;
      priceController.text = initialItem.inventory.productPackage?.sellingPrice
              .toStringAsFixed(2) ??
          '0.00';
      _calculateSubtotal();
      fetchFreshData(initialItem.inventory.productPackageId);
    } else {
      Get.back();
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: TTexts.errorUnknownMessage.tr);
    }
    priceController.addListener(_calculateSubtotal);
  }

  InventoryModel get _activeInventory =>
      freshInventoryData.value ?? initialItem.inventory;
  String get displayName =>
      _activeInventory.productPackage?.displayName ??
      initialItem.product?.name ??
      TTexts.productNameUnknown.tr;
  String get barcode =>
      _activeInventory.productPackage?.barcodeValue ?? TTexts.labelNoBarcode.tr;
  int get currentStock => _activeInventory.quantity;
  int get threshold => _activeInventory.reorderThreshold;

  String get brandName {
    final brand = initialItem.product?.brand;
    return (brand != null && brand.isNotEmpty) ? brand : TTexts.noBrand.tr;
  }

  String get categoryName {
    if (Get.isRegistered<InventoryController>()) {
      final categories = Get.find<InventoryController>().categories;
      final cat = categories.firstWhereOrNull(
          (c) => c.categoryId == initialItem.product?.categoryId);
      return cat?.name ?? TTexts.uncategorized.tr;
    }
    return TTexts.uncategorized.tr;
  }

  String get healthStatusText {
    if (currentStock <= 0) return TTexts.statusOut.tr;
    if (currentStock <= threshold) return TTexts.statusLow.tr;
    return TTexts.statusHealthy.tr;
  }

  Color get healthStatusColor {
    if (currentStock <= 0) return AppColors.stockOut;
    if (currentStock <= threshold) return AppColors.primary;
    return AppColors.stockIn;
  }

  bool get isProductActive =>
      initialItem.product?.activeStatus.toLowerCase() == 'active';

  int get totalQuantity {
    return selectedBatchesQty.values.fold(0, (sum, qty) => sum + qty);
  }

  void _calculateSubtotal() {
    final price = double.tryParse(priceController.text) ?? 0.0;
    totalPrice.value = totalQuantity * price;
  }

  Future<void> fetchFreshData(String packageId) async {
    if (packageId.isEmpty || packageId == 'null') return;
    try {
      isLoadingFreshData.value = true;
      final data = await _provider.getInventoryDetailByPackageId(packageId);
      freshInventoryData.value = InventoryModel.fromJson(data);

      final txs = await _provider.getInboundTransactionsForPackage(packageId);
      txs.sort((a, b) => a.createdAt!.compareTo(b.createdAt!)); // FIFO
      availableInboundTxs.assignAll(txs);

      selectedBatchesQty.clear();
      for (var tx in txs) {
        selectedBatchesQty[tx.transactionId!] = 0;
      }
    } catch (e) {
      debugPrint('Lỗi fetch data: $e');
    } finally {
      isLoadingFreshData.value = false;
    }
  }

  // 🟢 HÀM NÀY ĐÃ ĐƯỢC FIX LỖI "CỨNG ĐƠ" UI
  void updateBatchQty(String batchId, int newQty, int maxStock) {
    if (newQty < 0) newQty = 0;
    if (newQty > maxStock) {
      newQty = maxStock;
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.batchExceedsStock.tr);
    }

    selectedBatchesQty[batchId] = newQty;

    // 🟢 DÒNG CỐT LÕI: Đánh thức GetX render lại UI cho RxMap
    selectedBatchesQty.refresh();

    _calculateSubtotal();
  }

  Future<void> confirmAndAddToCart() async {
    try {
      final totalQty = totalQuantity;

      if (totalQty <= 0) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: "Please specify the quantity from the batches above.");
        return;
      }

      FullScreenLoaderUtils.openLoadingDialog(TTexts.loadingAddingToCart.tr);
      await Future.delayed(const Duration(milliseconds: 500));

      final package = _activeInventory.productPackage ??
          initialItem.inventory.productPackage;
      final packageId = _activeInventory.productPackageId.isNotEmpty
          ? _activeInventory.productPackageId
          : initialItem.inventory.productPackageId;

      final Map<String, dynamic> cartData = {
        'productPackageId': packageId,
        'displayName': displayName,
        'packageInfo': package,
        'importPrice': package?.importPrice ?? 0.0,
        'sellingPrice': package?.sellingPrice ?? 0.0,
        'currentStock': currentStock,
        'reorderThreshold': threshold,
      };

      Get.find<OutboundTransactionController>().addToCart(cartData,
          quantity: totalQty,
          customPrice: double.tryParse(priceController.text));

      FullScreenLoaderUtils.stopLoading();
      Get.until(
          (route) => route.settings.name == AppRoutes.outboundTransaction);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  @override
  void onClose() {
    priceController.dispose();
    super.onClose();
  }
}
