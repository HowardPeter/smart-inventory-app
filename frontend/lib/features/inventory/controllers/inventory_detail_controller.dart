import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/features/inventory/models/inventory_history_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

class InventoryDetailController extends GetxController with TErrorHandler {
  late InventoryInsightDisplayModel displayItem;
  late final bool canManageInventory;
  final RxBool isChartMode = false.obs;

  final List<InventoryInsightDisplayModel> historyStack = [];

  String cachedCategoryName = 'Uncategorized';
  List<InventoryInsightDisplayModel> cachedRelatedPackages = [];

  @override
  void onInit() {
    super.onInit();
    displayItem = Get.arguments as InventoryInsightDisplayModel;
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageInventory =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageInventory = false;
      // Ở đây có thể bỏ qua handleError nếu chỉ đơn giản là fallback quyền hạn,
      // nhưng nếu lỗi nghiêm trọng do mất session thì có thể gọi handleError(e);
    }
    _loadHeavyData();
  }

  void pushRelatedItem(InventoryInsightDisplayModel item) {
    final targetBarcode = item.inventory.productPackage?.barcodeValue;
    final existingIndex = historyStack.indexWhere((element) =>
        element.inventory.productPackage?.barcodeValue == targetBarcode);

    if (existingIndex != -1) {
      historyStack.removeRange(existingIndex, historyStack.length);
    } else {
      historyStack.add(displayItem);
    }
    displayItem = item;
    _loadHeavyData();
    update();
  }

  void goBack() {
    if (historyStack.isNotEmpty) {
      displayItem = historyStack.removeLast();
      _loadHeavyData();
      update();
    } else {
      Get.back();
    }
  }

  Future<void> _loadHeavyData() async {
    try {
      // TODO: Khi ráp API, thay đoạn logic local này bằng await repository.getDetail(...)
      final inventoryParent = Get.find<InventoryController>();

      final catId = displayItem.product?.categoryId;
      final cat = inventoryParent.categories
          .firstWhereOrNull((c) => c.categoryId == catId);
      cachedCategoryName = cat?.name ?? 'Uncategorized';

      final currentProductId = displayItem.product?.productId;
      final currentBarcode = displayItem.inventory.productPackage?.barcodeValue;

      if (currentProductId != null) {
        final related = inventoryParent.inventories.where((inv) {
          final pkg = inv.productPackage;
          return pkg?.productId == currentProductId &&
              pkg?.barcodeValue != currentBarcode;
        }).toList();

        cachedRelatedPackages = related
            .map((inv) => InventoryInsightDisplayModel(
                inventory: inv, product: displayItem.product))
            .toList();
      }
    } catch (e) {
      // FIX: Dùng Error Handler để bắt lỗi và show UI thay vì print()
      handleError(e);
    }
  }

  void toggleStatsMode(bool isChart) {
    isChartMode.value = isChart;
  }

  // Các Getter lấy thông tin (Giữ nguyên)
  String get name =>
      displayItem.inventory.productPackage?.displayName ??
      TTexts.unknownProduct.tr;
  String get barcode =>
      displayItem.inventory.productPackage?.barcodeValue ?? TTexts.na.tr;
  String? get imageUrl => displayItem.product?.imageUrl;

  String get brand => displayItem.product?.brand ?? '';
  String get barcodeType =>
      displayItem.inventory.productPackage?.barcodeType ?? 'EAN';
  int get lastCount => displayItem.inventory.lastCount;
  String get activeStatus =>
      displayItem.inventory.productPackage?.activeStatus ?? 'active';

  String get categoryName => cachedCategoryName;
  List<InventoryInsightDisplayModel> get relatedPackages =>
      cachedRelatedPackages;

  List<String> get tags {
    List<String> result = [categoryName, statusText];
    if (brand.isNotEmpty && brand != 'N/A') {
      result.add(brand);
    }
    if (activeStatus.toLowerCase() != 'active') {
      result.add('Inactive');
    }
    return result;
  }

  double get price => displayItem.inventory.productPackage?.sellingPrice ?? 0.0;
  double get importPrice =>
      displayItem.inventory.productPackage?.importPrice ?? 0.0;

  double get profitMargin {
    if (importPrice == 0) return 0.0;
    return ((price - importPrice) / importPrice) * 100;
  }

  int get quantity => displayItem.inventory.quantity;
  int get threshold => displayItem.inventory.reorderThreshold;

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
          note: TTexts.latestInventoryCount.tr,
        ),
        InventoryHistoryModel(
          date: '2026-03-25 14:30',
          type: InventoryActionType.iN,
          qty: 50,
          note: TTexts.restockFromSupplier.tr,
        ),
        InventoryHistoryModel(
          date: '2026-03-20 09:15',
          type: InventoryActionType.out,
          qty: -5,
          note: TTexts.salesOrder.tr,
        ),
      ];

  List<Map<String, dynamic>> get stockMovementData => [
        {'day': 'Mon', 'in': 120, 'out': 45},
        {'day': 'Tue', 'in': 0, 'out': 30},
        {'day': 'Wed', 'in': 50, 'out': 80},
        {'day': 'Thu', 'in': 10, 'out': 15},
        {'day': 'Fri', 'in': 200, 'out': 120},
        {'day': 'Sat', 'in': 0, 'out': 90},
        {'day': 'Sun', 'in': 20, 'out': 10},
      ];

  void handleMenuAction(String value) {
    if (value == TTexts.adjustStock) {
      TSnackbarsWidget.info(
          title: TTexts.info.tr, message: TTexts.featureComingSoon.tr);
    }
    if (value == TTexts.editItem) {
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
              // FIX: Chuyển callback thành async để call API và catch lỗi
              onPressed: () async {
                Get.back(); // Đóng Dialog trước
                await _performDeleteItem();
              },
              child: Text(TTexts.delete.tr,
                  style: const TextStyle(color: AppColors.alertText))),
        ],
      ),
    );
  }

  // FIX: Tách logic xóa ra hàm async riêng biệt để dùng try-catch với TErrorHandler
  Future<void> _performDeleteItem() async {
    try {
      // TODO: Call API xóa dữ liệu thật ở đây:
      // await inventoryRepository.deleteItem(displayItem.inventory.id);

      Get.back();

      TSnackbarsWidget.success(
        title: TTexts.itemDeletedSuccess.tr,
        message: TTexts.itemDeletedMessage.tr,
      );
    } catch (e) {
      // Nếu API xóa thất bại (rớt mạng, lỗi DB, hết hạn token...), lỗi sẽ tự popup qua Snackbar
      handleError(e);
    }
  }
}
