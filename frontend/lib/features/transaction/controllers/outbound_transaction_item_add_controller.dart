import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
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

  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();

  final RxInt itemQuantity = 1.obs;
  final RxDouble totalPrice = 0.0.obs;

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
    quantityController.addListener(_calculateSubtotal);
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

  // =========================================================
  // LOGIC TÍNH TOÁN
  // =========================================================
  void _calculateSubtotal() {
    itemQuantity.value = int.tryParse(quantityController.text) ?? 1;
    final price = double.tryParse(priceController.text) ?? 0.0;
    totalPrice.value = itemQuantity.value * price;
  }

  Future<void> fetchFreshData(String packageId) async {
    if (packageId.isEmpty || packageId == 'null') return;
    try {
      isLoadingFreshData.value = true;
      final data = await _provider.getInventoryDetailByPackageId(packageId);
      freshInventoryData.value = InventoryModel.fromJson(data);
    } catch (e) {
      debugPrint('Lỗi fetch data: $e');
    } finally {
      isLoadingFreshData.value = false;
    }
  }

  void incrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    if (current < currentStock) {
      quantityController.text = (current + 1).toString();
    } else {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.batchExceedsStock.tr);
    }
  }

  void decrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    if (current > 1) {
      quantityController.text = (current - 1).toString();
    }
  }

  Future<void> confirmAndAddToCart() async {
    try {
      final qty = int.tryParse(quantityController.text) ?? 1;

      if (qty > currentStock) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.batchExceedsStock.tr);
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
          quantity: qty, customPrice: double.tryParse(priceController.text));

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
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }
}
