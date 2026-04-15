import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
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
  final Rx<InventoryInsightDisplayModel?> currentDisplayItem =
      Rx<InventoryInsightDisplayModel?>(null);

  final RxBool isLoading = true.obs;
  late final bool canManageInventory;
  final RxBool isChartMode = false.obs;

  final List<InventoryInsightDisplayModel> historyStack = [];

  final RxString categoryNameObs = 'Uncategorized'.obs;
  final RxList<InventoryInsightDisplayModel> relatedPackagesList =
      <InventoryInsightDisplayModel>[].obs;

  final InventoryProvider _provider = InventoryProvider();

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

    // 🔥 FIX SHIMMER FREEZE: Dùng microtask để nhường 1 nhịp cho giao diện vẽ xong khung
    // Tránh xung đột luồng render Obx của Flutter
    Future.microtask(() => _initData());
  }

  void _initData() {
    final arg = Get.arguments;
    String? productId;

    if (arg is String) {
      productId = arg;
    } else if (arg is Map) {
      productId = arg['productId'];
    }

    final packageId = Get.parameters['packageId'];
    final barcode = Get.parameters['barcode'];

    _fetchDetailData(
        productId: productId, packageId: packageId, barcode: barcode);
  }

  Future<void> _fetchDetailData(
      {String? productId,
      String? packageId,
      String? barcode,
      bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        isLoading.value = true;
      }

      String? finalProductId = productId;

      if ((finalProductId == null || finalProductId.isEmpty) &&
          packageId != null &&
          packageId.isNotEmpty) {
        try {
          final pkgData = await _provider.getProductPackageDetail(packageId);
          finalProductId =
              pkgData['productId'] ?? pkgData['product']?['productId'];
        } catch (e) {
          debugPrint("Lỗi móc productId: $e");
        }
      }

      if (finalProductId == null || finalProductId.isEmpty) {
        throw Exception("Product ID or Package ID is missing");
      }

      final results = await Future.wait([
        _provider.getProductDetail(finalProductId),
        _provider.getPackagesByProductId(finalProductId),
      ]);

      final rawProduct = results[0] as Map<String, dynamic>;
      final rawPackages = results[1] as List<dynamic>;

      categoryNameObs.value =
          rawProduct['category']?['name'] ?? 'Uncategorized';
      final parentProduct = ProductModel.fromJson(rawProduct);

      List<InventoryInsightDisplayModel> related = [];
      InventoryInsightDisplayModel? initialItem;

      for (var pkgJson in rawPackages) {
        final pkgModel = ProductPackageModel.fromJson(pkgJson);

        final invJsonMap =
            Map<String, dynamic>.from(pkgJson['inventory'] ?? {});

        // 🔥 FIX CỐT LÕI (LỖI 0 RELATED): Bơm dữ liệu chống Null Exception
        invJsonMap['productPackage'] = pkgJson;
        invJsonMap['productPackageId'] = pkgModel.productPackageId;
        if (invJsonMap['inventoryId'] == null) {
          invJsonMap['inventoryId'] = 'INV_MOCK_${pkgModel.productPackageId}';
        }
        if (invJsonMap['quantity'] == null) {
          invJsonMap['quantity'] = 0;
        }

        final invModel = InventoryModel.fromJson(invJsonMap);

        final mappedItem = InventoryInsightDisplayModel(
          product: parentProduct,
          inventory: invModel,
        );

        related.add(mappedItem);

        if (packageId != null && pkgModel.productPackageId == packageId) {
          initialItem = mappedItem;
        } else if (initialItem == null &&
            barcode != null &&
            pkgModel.barcodeValue == barcode) {
          initialItem = mappedItem;
        }
      }

      if (initialItem == null && related.isNotEmpty) {
        initialItem = related.first;
      }

      if (initialItem != null &&
          initialItem.inventory.productPackageId.isNotEmpty) {
        // Giờ các Item đã có ID đàng hoàng, removeWhere sẽ chỉ xóa đúng 1 dòng!
        related.removeWhere((item) =>
            item.inventory.productPackageId ==
            initialItem!.inventory.productPackageId);
      }

      relatedPackagesList.assignAll(related);
      currentDisplayItem.value = initialItem;
    } catch (e) {
      print('👉 [ERROR LÚC FETCH]: $e');
      handleError(e);
    } finally {
      // 🔥 XÓA HÀM update() - CHỈ DÙNG Rx ĐỂ OBX TỰ XỬ LÝ!
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    final currentProductId = currentDisplayItem.value?.product?.productId;
    final currentPkgId = currentDisplayItem.value?.inventory.productPackageId;
    if (currentProductId != null) {
      await _fetchDetailData(
          productId: currentProductId,
          packageId: currentPkgId,
          isRefresh: true);
    }
  }

  void pushRelatedItem(InventoryInsightDisplayModel newItem) {
    if (currentDisplayItem.value != null) {
      final targetPkgId = newItem.inventory.productPackageId;

      final existingIndex = historyStack.indexWhere(
          (element) => element.inventory.productPackageId == targetPkgId);

      if (existingIndex != -1) {
        historyStack.removeRange(existingIndex, historyStack.length);
      } else {
        historyStack.add(currentDisplayItem.value!);
      }

      currentDisplayItem.value = newItem;

      final productId = newItem.product?.productId;
      if (productId != null) {
        _fetchDetailData(
            productId: productId, packageId: targetPkgId, isRefresh: true);
      }
    }
  }

  void goBack() {
    if (historyStack.isNotEmpty) {
      final oldItem = historyStack.removeLast();
      currentDisplayItem.value = oldItem;
    } else {
      Get.back();
    }
  }

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

  String get categoryName => categoryNameObs.value;
  List<InventoryInsightDisplayModel> get relatedPackages => relatedPackagesList;

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
      final product = currentDisplayItem.value?.product;

      if (product != null) {
        Get.toNamed(AppRoutes.productCatalogDetail, arguments: product)
            ?.then((_) {
          if (Get.isRegistered<InventoryController>()) {
            Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
          }
          if (Get.isRegistered<InventoryInsightController>()) {
            Get.find<InventoryInsightController>().refreshData();
          }
        });
      } else {
        TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.productDataMissing.tr,
        );
      }
    }
  }

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
