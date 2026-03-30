import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/features/inventory/models/inventory_history_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';

class InventoryDetailController extends GetxController with TErrorHandler {
  Rx<InventoryInsightDisplayModel?> currentDisplayItem =
      Rx<InventoryInsightDisplayModel?>(null);

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

    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageInventory =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageInventory = false;
    }

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
  // GỌI API LẤY TOÀN BỘ DATA (HỖ TRỢ REFRESH)
  // ==========================================
  Future<void> _fetchDetailData(String productId,
      {bool isRefresh = false}) async {
    try {
      // FIX LỖI 2 (SHIMMER): Luôn bật Loading để hiện Shimmer, bất kể là refresh hay vào lần đầu
      isLoading.value = true;
      update(); // Báo GetBuilder vẽ lại để hiện Shimmer

      // Giữ độ trễ để User nhìn thấy Shimmer (chỉ dùng khi test ngầm, thật thì xóa đi)
      await Future.delayed(const Duration(milliseconds: 1500));

      final rawData = await _provider.getProductDetail(productId);

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

        if (targetBarcodeToFocus != null &&
            pkgModel.barcodeValue == targetBarcodeToFocus) {
          initialItem = mappedItem;
        }
      }

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
      // Kết thúc tải dữ liệu
      isLoading.value = false;
      update(); // Vẽ lại để tắt Shimmer hiện nội dung
    }
  }

  // ==========================================
  // PULL TO REFRESH ACTION
  // ==========================================
  Future<void> refreshData() async {
    final currentProductId = currentDisplayItem.value?.product?.productId;
    if (currentProductId != null) {
      await _fetchDetailData(currentProductId, isRefresh: true);
    }
  }

  // ==========================================
  // XỬ LÝ CHUYỂN TRANG (RELATED PACKAGES)
  // ==========================================
  void pushRelatedItem(InventoryInsightDisplayModel newItem) {
    if (currentDisplayItem.value != null) {
      final targetBarcode = newItem.inventory.productPackage?.barcodeValue;

      // FIX LỖI 1 (HISTORY): Kiểm tra xem item chuẩn bị vào đã có trong lịch sử chưa
      final existingIndex = historyStack.indexWhere((element) =>
          element.inventory.productPackage?.barcodeValue == targetBarcode);

      if (existingIndex != -1) {
        // Nếu đã có trong lịch sử -> Xóa toàn bộ các trang phía trên nó để quay ngược lại (Pop to)
        historyStack.removeRange(existingIndex, historyStack.length);
      } else {
        // Nếu chưa có -> Thêm trang hiện tại vào lịch sử
        historyStack.add(currentDisplayItem.value!);
      }

      // 2. Chuyển Item mới thành Item chính
      currentDisplayItem.value = newItem;
      targetBarcodeToFocus = targetBarcode;

      // 3. Gọi fetch dữ liệu mới (đã sửa ở trên để hiện Shimmer)
      final productId = newItem.product?.productId;
      if (productId != null) {
        _fetchDetailData(productId, isRefresh: true);
      } else {
        update();
      }
    }
  }

  // ==========================================
  // HÀM BACK CHUẨN (RÚT ITEM KHỎI STACK)
  // ==========================================
  void goBack() {
    if (historyStack.isNotEmpty) {
      final oldItem = historyStack.removeLast();
      currentDisplayItem.value = oldItem;
      targetBarcodeToFocus = oldItem.inventory.productPackage?.barcodeValue;
      update(); // Update UI
    } else {
      // Nếu Stack rỗng thì mới thoát trang Detail
      Get.back();
    }
  }

  // ... Các hàm toggleStatsMode và getters bên dưới giữ nguyên không đổi ...
  void toggleStatsMode(bool isChart) {
    isChartMode.value = isChart;
  }

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
    if (quantity <= 0) return 0.0;

    if (threshold <= 0) return 1.0;
    final ratio = quantity / (threshold * 2);
    return ratio > 1.0 ? 1.0 : ratio;
  }

  Color get stockHealthColor {
    if (quantity <= 0) return AppColors.alertText;
    if (quantity <= threshold) return AppColors.primary;
    return AppColors.stockIn;
  }

  String get statusText {
    // ĐÃ FIX: Bắt chặt điều kiện <= 0
    if (quantity <= 0) return TTexts.tabOutStock.tr;
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

  void handleMenuAction(String actionKey) {
    if (actionKey == TTexts.viewProductInfo) {
      // Lấy dữ liệu product từ item đang hiển thị trên màn hình
      final product = currentDisplayItem.value?.product;

      if (product != null) {
        // Điều hướng sang trang Catalog Detail và truyền Model sản phẩm sang
        Get.toNamed(
          AppRoutes.productCatalogDetail,
          arguments: product,
        );
      } else {
        // Báo lỗi nếu dữ liệu sản phẩm bị null
        TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.productDataMissing.tr,
        );
      }
    }
  }

  // TODO: Doi data that cho bieu do, can Transaction
  List<Map<String, dynamic>> get stockMovementData => [
        {'day': 'Mon', 'in': 120, 'out': 45},
        {'day': 'Tue', 'in': 80, 'out': 60},
        {'day': 'Wed', 'in': 150, 'out': 90},
        {'day': 'Thu', 'in': 90, 'out': 40},
        {'day': 'Fri', 'in': 200, 'out': 150},
        {'day': 'Sat', 'in': 60, 'out': 20},
        {'day': 'Sun', 'in': 40, 'out': 10},
      ];
}
