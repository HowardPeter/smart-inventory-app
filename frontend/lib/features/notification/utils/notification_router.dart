import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart'; // Tuỳ chọn để show lỗi

class NotificationRouter {
  /// Xử lý điều hướng dựa trên loại thông báo và ID đính kèm
  static Future<void> navigate(
      String type, String? referenceId, String? notificationStoreId) async {
    if (type.isEmpty) return;

    debugPrint(
        "🚀 [NotificationRouter] Điều hướng: type=$type, refId=$referenceId, storeId=$notificationStoreId");

    // ==========================================
    // 1. KIỂM TRA & XỬ LÝ SWITCH STORE
    // ==========================================
    if (notificationStoreId != null && notificationStoreId.isNotEmpty) {
      final storeService = Get.find<StoreService>();

      // So sánh với ID store đang chạy trong app
      if (notificationStoreId != storeService.currentStoreId.value) {
        debugPrint("🔄 Tự động chuyển đổi sang Store: $notificationStoreId...");

        try {
          // Bạn có thể show Loading Dialog ở đây nếu muốn
          // TScreenLoader.showLoading();

          final workspaceProvider = WorkspaceProvider();

          // Lấy danh sách các cửa hàng của User (Tương tự logic trong StoreSelectionController)
          final List<StoreModel> myStores =
              await workspaceProvider.getMyStores();

          // Tìm Store khớp với storeId từ Notification
          final targetStore = myStores.firstWhere(
            (store) => store.storeId == notificationStoreId,
            orElse: () => throw Exception(
                'Không tìm thấy cửa hàng này hoặc bạn đã bị xóa quyền.'),
          );

          // Cập nhật toàn bộ data vào StoreService (RAM & Storage)
          await storeService.saveSelectedStore(
            targetStore.storeId,
            targetStore.name,
            targetStore.role,
            targetStore.inviteCode ?? '',
          );

          debugPrint("✅ Đổi Store thành công: ${targetStore.name}");

          // NOTE: Vì Store đã thay đổi, nếu app của bạn không dùng getX (ever/obx) để tự động
          // reload data các trang, thì tốt nhất bạn nên đưa user về trang Chủ (Home)
          // để data fetch lại từ đầu. Hoặc gọi hàm refresh tương ứng.

          // TScreenLoader.stopLoading();
        } catch (e) {
          debugPrint("⚠️ Lỗi khi switch store: $e");
          // TScreenLoader.stopLoading();
          TSnackbarsWidget.error(
              title: 'Lỗi chuyển cửa hàng',
              message: 'Không thể truy cập vào cửa hàng của thông báo này.');
          return; // Dừng việc điều hướng nếu switch store thất bại
        }
      }
    }

    // ==========================================
    // 2. TẮT CÁC DIALOG/BOTTOM SHEET TRƯỚC KHI CHUYỂN TRANG
    // ==========================================
    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
    }

    // ==========================================
    // 3. ĐIỀU HƯỚNG NHƯ BÌNH THƯỜNG
    // ==========================================
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

      case 'SYSTEM':
      case 'UNKNOWN':
        if (Get.currentRoute != AppRoutes.notification) {
          Get.toNamed(AppRoutes.notification);
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
