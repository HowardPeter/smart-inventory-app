import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/features/inventory/models/inventory_history_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
// Provider & Model thật
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';

class InventoryDetailController extends GetxController with TErrorHandler {
  // Biến lưu trữ Item đang hiển thị (Có thể null trong lúc đợi tải data)
  Rx<InventoryInsightDisplayModel?> currentDisplayItem =
      Rx<InventoryInsightDisplayModel?>(null);

  // Trạng thái loading toàn trang
  final RxBool isLoading = true.obs;

  late final bool canManageInventory;
  final RxBool isChartMode = false.obs;

  final List<InventoryInsightDisplayModel> historyStack = [];
  String cachedCategoryName = 'Uncategorized';
  List<InventoryInsightDisplayModel> cachedRelatedPackages = [];

  final InventoryProvider _provider = InventoryProvider();
  String? targetBarcodeToFocus;

  @override
  void onInit() {
    super.onInit();

    // Check Quyền
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageInventory =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageInventory = false;
    }

    // Nhận ID và Barcode mục tiêu
    final productId = Get.arguments as String?;
    targetBarcodeToFocus = Get.parameters['barcode'];

    if (productId != null) {
      _fetchDetailData(productId);
    } else {
      isLoading.value = false;
      handleError("Product ID is missing");
    }
  }

  // ==========================================
  // GỌI API LẤY TOÀN BỘ DATA
  // ==========================================
  Future<void> _fetchDetailData(String productId) async {
    try {
      isLoading.value = true;
      update(); // Báo View hiển thị Spinner

      // 1. Gọi API (Đảm bảo getProductDetail đã có trong InventoryProvider)
      final rawData = await _provider.getProductDetail(productId);

      // 2. Parse Dữ liệu
      cachedCategoryName = rawData['category']?['name'] ?? 'Uncategorized';
      final parentProduct = ProductModel.fromJson(rawData);
      final packagesList = rawData['productPackages'] as List<dynamic>? ?? [];

      List<InventoryInsightDisplayModel> related = [];
      InventoryInsightDisplayModel? initialItem;

      for (var pkgJson in packagesList) {
        final pkgModel = ProductPackageModel.fromJson(pkgJson);
        // 1. Tạo một bản sao JSON của inventory có thể chỉnh sửa
        final invJsonMap =
            Map<String, dynamic>.from(pkgJson['inventory'] ?? {});

        // 2. Nhét thẳng gói pkgJson vào trong inventory json
        // (Lưu ý: key 'productPackage' này phải đúng với key mà hàm InventoryModel.fromJson của bạn đang đọc)
        invJsonMap['productPackage'] = pkgJson;

        // 3. Parse Model từ cục JSON đã được nhét đủ data
        final invModel = InventoryModel.fromJson(invJsonMap);

        // XÓA dòng này đi vì data đã được parse ở trên:
        // invModel.productPackage = pkgModel;

        final mappedItem = InventoryInsightDisplayModel(
          product: parentProduct,
          inventory: invModel,
        );

        related.add(mappedItem);

        // Tìm item đúng barcode
        if (targetBarcodeToFocus != null &&
            pkgModel.barcodeValue == targetBarcodeToFocus) {
          initialItem = mappedItem;
        }
      }

      // 3. Phân chia Item Chính và Các gói Related
      if (initialItem != null) {
        related.removeWhere((item) =>
            item.inventory.productPackage?.barcodeValue ==
            targetBarcodeToFocus);
      } else if (related.isNotEmpty) {
        initialItem = related.first;
        related.removeAt(0);
      }

      cachedRelatedPackages = related;
      currentDisplayItem.value = initialItem;
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
      update(); // Vẽ lại giao diện
    }
  }

  // ==========================================
  // XỬ LÝ CHUYỂN TRANG (RELATED PACKAGES)
  // ==========================================
  void pushRelatedItem(InventoryInsightDisplayModel newItem) {
    if (currentDisplayItem.value != null) {
      historyStack.add(currentDisplayItem.value!);
      currentDisplayItem.value = newItem;

      final allPackages = [...cachedRelatedPackages, historyStack.last];
      allPackages.removeWhere((pkg) =>
          pkg.inventory.productPackage?.barcodeValue ==
          newItem.inventory.productPackage?.barcodeValue);
      cachedRelatedPackages = allPackages;

      // Có thể gọi _fetchDetailData(newItem.product!.productId) nếu muốn data luôn cực fresh
      update();
    }
  }

  void goBack() {
    if (historyStack.isNotEmpty) {
      final oldItem = historyStack.removeLast();

      final allPackages = [...cachedRelatedPackages, currentDisplayItem.value!];
      allPackages.removeWhere((pkg) =>
          pkg.inventory.productPackage?.barcodeValue ==
          oldItem.inventory.productPackage?.barcodeValue);
      cachedRelatedPackages = allPackages;

      currentDisplayItem.value = oldItem;
      update();
    } else {
      Get.back();
    }
  }

  void toggleStatsMode(bool isChart) {
    isChartMode.value = isChart;
  }

  // ==========================================
  // GETTERS LẤY DỮ LIỆU BẢO VỆ NULL
  // ==========================================
  InventoryInsightDisplayModel? get _item => currentDisplayItem.value;

  String get name =>
      _item?.inventory.productPackage?.displayName ?? TTexts.unknownProduct.tr;
  String get barcode =>
      _item?.inventory.productPackage?.barcodeValue ?? TTexts.na.tr;
  String? get imageUrl => _item?.product?.imageUrl;

  String get brand => _item?.product?.brand ?? '';
  String get barcodeType =>
      _item?.inventory.productPackage?.barcodeType ?? 'EAN';
  int get lastCount => _item?.inventory.lastCount ?? 0;
  String get activeStatus =>
      _item?.inventory.productPackage?.activeStatus ?? 'active';

  String get categoryName => cachedCategoryName;
  List<InventoryInsightDisplayModel> get relatedPackages =>
      cachedRelatedPackages;

  List<String> get tags {
    List<String> result = [categoryName, statusText];
    if (brand.isNotEmpty && brand != 'N/A') result.add(brand);
    if (activeStatus.toLowerCase() != 'active') result.add('Inactive');
    return result;
  }

  double get price => _item?.inventory.productPackage?.sellingPrice ?? 0.0;
  double get importPrice => _item?.inventory.productPackage?.importPrice ?? 0.0;

  double get profitMargin {
    if (importPrice == 0) return 0.0;
    return ((price - importPrice) / importPrice) * 100;
  }

  int get quantity => _item?.inventory.quantity ?? 0;
  int get threshold => _item?.inventory.reorderThreshold ?? 0;

  int get totalStockIn => quantity + 35;
  int get totalStockOut => 35;

  double get stockHealthRatio {
    if (threshold <= 0) return 1.0;
    final ratio = quantity / (threshold * 2);
    return ratio > 1.0 ? 1.0 : ratio;
  }

  Color get stockHealthColor {
    if (quantity == 0) return AppColors.alertText;
    if (quantity <= threshold) return AppColors.primary;
    return AppColors.stockIn;
  }

  String get statusText {
    if (quantity == 0) return TTexts.tabOutStock.tr;
    if (quantity <= threshold) return TTexts.tabLowStock.tr;
    return TTexts.tabHealthy.tr;
  }

  List<InventoryHistoryModel> get inventoryHistory => [
        InventoryHistoryModel(
            date: 'Just now',
            type: InventoryActionType.adjust,
            qty: lastCount,
            note: TTexts.latestInventoryCount.tr),
      ];

  List<Map<String, dynamic>> get stockMovementData => [
        {'day': 'Mon', 'in': 120, 'out': 45},
      ];

  // ==========================================
  // ACTIONS MENU
  // ==========================================
  void handleMenuAction(String value) {
    if (value == TTexts.adjustStock || value == TTexts.editItem) {
      TSnackbarsWidget.info(
          title: TTexts.info.tr, message: TTexts.featureComingSoon.tr);
    }
    if (value == TTexts.deleteItem) _showDeleteConfirmDialog();
  }

  void _showDeleteConfirmDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(TTexts.deleteConfirmation.tr),
        content: Text(TTexts.confirmDeleteText.tr),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text(TTexts.cancel.tr,
                  style: const TextStyle(color: AppColors.softGrey))),
          TextButton(
              onPressed: () async {
                Get.back();
                await _performDeleteItem();
              },
              child: Text(TTexts.delete.tr,
                  style: const TextStyle(color: AppColors.alertText))),
        ],
      ),
    );
  }

  Future<void> _performDeleteItem() async {
    try {
      // Gọi API xóa ở đây
      Get.back();
      TSnackbarsWidget.success(
          title: TTexts.itemDeletedSuccess.tr,
          message: TTexts.itemDeletedMessage.tr);
    } catch (e) {
      handleError(e);
    }
  }
}
