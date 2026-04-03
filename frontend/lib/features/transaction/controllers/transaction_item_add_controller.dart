import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/transaction/providers/transaction_provider.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/routes/app_routes.dart';

class TransactionItemAddController extends GetxController with TErrorHandler {
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
      priceController.text = initialItem.inventory.productPackage?.importPrice
              .toStringAsFixed(2) ??
          '0.00';
      _calculateSubtotal();

      // 🟢 DEBUG LOG: In ra để xem ID truyền sang từ trang Search có sống không
      debugPrint('========== [DEBUG: INIT TRANG ADD] ==========');
      debugPrint('1. Tên Sản phẩm (Display Name): $displayName');
      debugPrint(
          '2. ID Gói (Từ Inventory): ${initialItem.inventory.productPackageId}');
      debugPrint(
          '3. ID Gói (Từ Package Info): ${initialItem.inventory.productPackage?.productPackageId}');
      debugPrint('=============================================');

      fetchFreshData(initialItem.inventory.productPackageId);
    } else {
      Get.back();
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.errorUnknownMessage.tr); // Something went wrong
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

  int get currentStock => _activeInventory.quantity;
  int get threshold => _activeInventory.reorderThreshold;

  String get healthStatusText {
    if (currentStock <= 0) return TTexts.tabOutStock.tr;
    if (currentStock <= threshold) return TTexts.tabLowStock.tr;
    return TTexts.tabHealthy.tr;
  }

  Color get healthStatusColor {
    if (currentStock <= 0) return AppColors.stockOut;
    if (currentStock <= threshold) return AppColors.primary;
    return AppColors.stockIn;
  }

  bool get isProductActive =>
      initialItem.product?.activeStatus.toLowerCase() == 'active';

  void _calculateSubtotal() {
    itemQuantity.value = int.tryParse(quantityController.text) ?? 1;
    final price = double.tryParse(priceController.text) ?? 0.0;
    totalPrice.value = itemQuantity.value * price;
  }

  Future<void> fetchFreshData(String packageId) async {
    // 🟢 DEBUG LOG: Xem gói gửi đi fetch là gì
    debugPrint('========== [DEBUG: FETCH DỮ LIỆU TỒN KHO] ==========');
    debugPrint('PackageId gửi đi lấy API: "$packageId"');

    if (packageId.isEmpty || packageId == 'null') {
      debugPrint('❌ BỊ CHẶN: PackageId trống hoặc chuỗi "null", dừng gọi API!');
      // Xóa Snackbar ở đây cho đỡ phiền người dùng
      return;
    }

    try {
      isLoadingFreshData.value = true;
      final data = await _provider.getInventoryDetailByPackageId(packageId);
      freshInventoryData.value = InventoryModel.fromJson(data);
      debugPrint('✅ FETCH THÀNH CÔNG: Đã lấy được dữ liệu mới nhất!');
    } catch (e) {
      debugPrint('❌ LỖI FETCH DATA NGẦM: $e');
    } finally {
      isLoadingFreshData.value = false;
      debugPrint('====================================================');
    }
  }

  void incrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    quantityController.text = (current + 1).toString();
  }

  void decrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    if (current > 1) {
      quantityController.text = (current - 1).toString();
    }
  }

  Future<void> confirmAndAddToCart() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loadingAddingToCart.tr);
      await Future.delayed(const Duration(milliseconds: 500));

      if (Get.isRegistered<InboundTransactionController>()) {
        final inboundCtrl = Get.find<InboundTransactionController>();
        final package = _activeInventory.productPackage ??
            initialItem.inventory.productPackage;

        // 🟢 TIẾN HÀNH THU THẬP TẤT CẢ CÁC NGUỒN ID CÓ THỂ
        final String activeId = _activeInventory.productPackageId;
        final String packageInfoId = package?.productPackageId ?? '';
        final String initialId = initialItem.inventory.productPackageId;

        // Dò xem cái nào có dữ liệu thật sự
        String realPkgId = '';
        if (activeId.isNotEmpty && activeId != 'null') {
          realPkgId = activeId;
        } else if (packageInfoId.isNotEmpty && packageInfoId != 'null') {
          realPkgId = packageInfoId;
        } else if (initialId.isNotEmpty && initialId != 'null') {
          realPkgId = initialId;
        }

        if (realPkgId.isEmpty) {
          debugPrint('========== [❌ LỖI NGHIÊM TRỌNG: ADD TO CART] ==========');
          debugPrint('Không thể tìm thấy ID gói nào hợp lệ để thêm vào giỏ:');
          debugPrint('1. Từ _activeInventory: "$activeId"');
          debugPrint('2. Từ packageInfo: "$packageInfoId"');
          debugPrint('3. Từ initialItem: "$initialId"');
          debugPrint(
              '==========================================================');

          FullScreenLoaderUtils.stopLoading();
          TSnackbarsWidget.error(
            title: TTexts.errorTitle.tr,
            message: TTexts.errorUnknownMessage.tr,
          );
          return;
        }

        // Nếu ID ổn, thêm vào giỏ
        inboundCtrl.addToCart(
          {
            'productPackageId': realPkgId,
            'displayName': displayName,
            'packageInfo': package,
            'importPrice': package?.importPrice ?? 0.0,
            'currentStock': currentStock,
            'reorderThreshold': threshold,
          },
          quantity: int.tryParse(quantityController.text) ?? 1,
          customPrice: double.tryParse(priceController.text),
        );
      }

      FullScreenLoaderUtils.stopLoading();
      Get.until((route) => route.settings.name == AppRoutes.inboundTransaction);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      debugPrint('========== [❌ LỖI EXCEPTION THÊM GIỎ HÀNG] ==========');
      debugPrint(e.toString());
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
