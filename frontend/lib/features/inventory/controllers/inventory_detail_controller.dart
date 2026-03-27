import 'package:flutter/material.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

class InventoryDetailController extends GetxController {
  late InventoryInsightDisplayModel displayItem;
  late final bool canManageInventory;
  final RxBool isChartMode = false.obs;

  // ==========================================
  // CÁC BIẾN QUẢN LÝ LỊCH SỬ & CHỐNG LAG
  // ==========================================
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
    }

    // Load data nặng 1 lần duy nhất để chống lag
    _loadHeavyData();
  }

  // ==========================================
  // 3. CÁC HÀM XỬ LÝ CHUYỂN TRANG NỘI BỘ (Fix lỗi bạn đang gặp)
  // ==========================================

// Thay thế hàm pushRelatedItem cũ bằng hàm này:

  void pushRelatedItem(InventoryInsightDisplayModel item) {
    final targetBarcode = item.inventory.productPackage?.barcodeValue;

    // 1. Tìm xem cái item sắp mở này đã có trong lịch sử (historyStack) chưa
    final existingIndex = historyStack.indexWhere((element) =>
        element.inventory.productPackage?.barcodeValue == targetBarcode);

    if (existingIndex != -1) {
      // TRƯỜNG HỢP 1: NẾU ĐÃ CÓ TRONG LỊCH SỬ (Ví dụ: vòng lại trang cũ)
      // Cắt bỏ toàn bộ các trang nằm sau vị trí đó để dọn rác, không lưu thêm.
      historyStack.removeRange(existingIndex, historyStack.length);
    } else {
      // TRƯỜNG HỢP 2: NẾU LÀ TRANG MỚI HOÀN TOÀN
      // Lưu item hiện tại vào lịch sử bình thường
      historyStack.add(displayItem);
    }

    // 2. Cập nhật item mới
    displayItem = item;

    // 3. Tính toán lại dữ liệu
    _loadHeavyData();

    // 4. Báo UI cập nhật (nhờ có key trong AnimatedSwitcher nên vẫn sẽ có animation mượt mà)
    update();
  }

  void goBack() {
    if (historyStack.isNotEmpty) {
      // 1. Lấy lại item trước đó
      displayItem = historyStack.removeLast();

      // 2. Reload lại data
      _loadHeavyData();

      // 3. Update UI
      update();
    } else {
      Get.back();
    }
  }

  // ==========================================
  // 4. HÀM TỐI ƯU HIỆU NĂNG CHỐNG LAG (Chỉ tính toán 1 lần)
  // ==========================================
  void _loadHeavyData() {
    try {
      final inventoryParent = Get.find<InventoryController>();

      // Tìm Category Name
      final catId = displayItem.product?.categoryId;
      final cat = inventoryParent.categories
          .firstWhereOrNull((c) => c.categoryId == catId);
      cachedCategoryName = cat?.name ?? 'Uncategorized';

      // Tìm Related Packages (những gói khác của cùng 1 sản phẩm)
      final currentProductId = displayItem.product?.productId;
      final currentBarcode = displayItem.inventory.productPackage?.barcodeValue;

      if (currentProductId != null) {
        final related = inventoryParent.inventories.where((inv) {
          final pkg = inv.productPackage;
          // Lọc: cùng Product ID nhưng khác Barcode (để không hiện chính nó trong mục Related)
          return pkg?.productId == currentProductId &&
              pkg?.barcodeValue != currentBarcode;
        }).toList();

        cachedRelatedPackages = related
            .map((inv) => InventoryInsightDisplayModel(
                inventory: inv, product: displayItem.product))
            .toList();
      }
    } catch (e) {
      // print("Error loading data: $e");
    }
  }

  void toggleStatsMode(bool isChart) {
    isChartMode.value = isChart;
  }

  // ==========================================
  // 5. CÁC GETTER LẤY THÔNG TIN
  // ==========================================
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

  // Trỏ thẳng vào biến Cache để không bị lag
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

  List<Map<String, dynamic>> get inventoryHistory => [
        {
          'date': 'Just now',
          'type': 'ADJUST',
          'qty': lastCount,
          'note': 'Latest Inventory Count'
        },
        {
          'date': '2026-03-25 14:30',
          'type': 'IN',
          'qty': 50,
          'note': 'Restock from Supplier'
        },
        {
          'date': '2026-03-20 09:15',
          'type': 'OUT',
          'qty': -5,
          'note': 'Sales Order #1023'
        },
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
          title: "Info", message: "Adjust stock feature coming soon");
    }
    if (value == TTexts.editItem) {
      TSnackbarsWidget.info(
          title: "Info", message: "Edit item feature coming soon");
    }
    if (value == TTexts.deleteItem) _onDeleteItem();
  }

  void _onDeleteItem() {
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
              onPressed: () {
                Get.back();
                Get.back();
                Get.snackbar("Deleted", "Item deleted!");
              },
              child: Text(TTexts.delete.tr,
                  style: const TextStyle(color: AppColors.alertText))),
        ],
      ),
    );
  }
}
