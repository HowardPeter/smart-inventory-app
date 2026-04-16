import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class NotificationRouter {
  static Future<void> navigate(
      String type, String? referenceId, String? notificationStoreId) async {
    if (type.isEmpty) return;

    debugPrint(
        "🚀 [NotificationRouter] Điều hướng: type=$type, refId=$referenceId, storeId=$notificationStoreId");

    // Xác định xem lệnh này có phải do Splash vừa bàn giao không
    bool isFromSplash =
        Get.currentRoute == AppRoutes.splash || Get.currentRoute.isEmpty;
    bool didSwitchStore = false;

    // ==========================================
    // 1. XỬ LÝ SWITCH STORE
    // ==========================================
    if (notificationStoreId != null && notificationStoreId.isNotEmpty) {
      final storeService = Get.find<StoreService>();

      if (notificationStoreId != storeService.currentStoreId.value) {
        debugPrint("🔄 [NotificationRouter] Đang thực hiện Switch Store...");
        try {
          final workspaceProvider = WorkspaceProvider();
          final List<StoreModel> myStores =
              await workspaceProvider.getMyStores();

          final targetStore = myStores.firstWhere(
            (store) => store.storeId == notificationStoreId,
            orElse: () => throw Exception('Không tìm thấy cửa hàng.'),
          );

          await storeService.saveSelectedStore(
            targetStore.storeId,
            targetStore.name,
            targetStore.role,
            targetStore.inviteCode ?? '',
          );

          didSwitchStore = true;
          debugPrint("✅ [NotificationRouter] Đổi Store thành công.");
        } catch (e) {
          debugPrint("⚠️ [NotificationRouter] Lỗi Switch Store: $e");
          TSnackbarsWidget.error(
              title: 'Lỗi', message: 'Không thể truy cập cửa hàng.');

          // Cứu cánh: Nếu lỗi switch mà đang ở Splash thì đẩy vào Home của Store hiện tại
          if (isFromSplash) Get.offAllNamed(AppRoutes.main);
          return;
        }
      }
    }

    // Tắt dialog nếu có
    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
    }

    // ==========================================
    // 2. KHỞI TẠO MÔI TRƯỜNG CHUẨN
    // ==========================================
    // BẮT BUỘC reset về Main khi: Đã đổi Store HOẶC App vừa khởi động từ Splash
    if (didSwitchStore || isFromSplash) {
      Get.offAllNamed(AppRoutes.main);
      await Future.delayed(
          const Duration(milliseconds: 500)); // Chờ Main build xong layout
    }

    // ==========================================
    // 3. ĐIỀU HƯỚNG VÀO TRANG CHI TIẾT
    // ==========================================
    debugPrint("🎯 [NotificationRouter] Mở trang chi tiết: $type");
    switch (type) {
      case 'LOW_STOCK':
      case 'INVENTORY_CHANGED':
        if (referenceId != null && referenceId.isNotEmpty) {
          Get.toNamed(AppRoutes.inventoryDetail, arguments: referenceId);
        } else {
          Get.toNamed(AppRoutes.lowStock);
        }
        break;

      case 'BATCH_LOW_STOCK':
        Get.toNamed(AppRoutes.lowStock);
        break;

      case 'ORDER_CREATED':
      case 'IMPORT':
      case 'EXPORT':
        if (referenceId != null && referenceId.isNotEmpty) {
          Get.toNamed(AppRoutes.transactionDetail,
              arguments: {'id': referenceId});
        } else {
          Get.toNamed(AppRoutes.transactionSummary);
        }
        break;

      default:
        if (Get.currentRoute != AppRoutes.notification) {
          Get.toNamed(AppRoutes.notification);
        }
        break;
    }
  }
}
