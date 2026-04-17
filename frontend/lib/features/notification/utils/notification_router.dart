import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRouter {
  static Future<void> navigate(
      String type, String? referenceId, String? notificationStoreId) async {
    if (type.isEmpty) return;

    debugPrint(
        "🚀 [Router] Bắt đầu điều hướng: $type | StoreId: $notificationStoreId");

    // Nếu user đang mở Dialog / BottomSheet thì phải tắt nó trước
    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
      // Chờ 300ms cho animation đóng popup hoàn tất để tránh xung đột GetX
      await Future.delayed(const Duration(milliseconds: 300));
    }
    final supabase = Supabase.instance.client;
    final storeService = Get.find<StoreService>();

    bool isFromSplash =
        Get.currentRoute == AppRoutes.splash || Get.currentRoute.isEmpty;
    bool needsSwitchStore = notificationStoreId != null &&
        notificationStoreId.isNotEmpty &&
        notificationStoreId != storeService.currentStoreId.value;

    bool didSwitchStore = false;

    if (needsSwitchStore) {
      try {
        final workspaceProvider = WorkspaceProvider();
        final List<StoreModel> myStores = await workspaceProvider.getMyStores();

        final targetStore = myStores.firstWhere(
          (store) => store.storeId == notificationStoreId,
          orElse: () => throw Exception('Không tìm thấy cửa hàng.'),
        );

        await storeService.saveSelectedStore(targetStore.storeId,
            targetStore.name, targetStore.role, targetStore.inviteCode ?? '');

        // Đẩy một màn hình Loading lên trước để đổi Route Context.
        // Vừa giúp người dùng biết app đang tải dữ liệu Store mới, vừa chống lỗi kẹt của GetX.
        Get.to(
          () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          transition: Transition.noTransition,
        );

        // Đợi màn hình tạm hiện ra hoàn tất
        await Future.delayed(const Duration(milliseconds: 300));

        didSwitchStore = true;
        debugPrint("✅ [Router] Cập nhật Database sang Store A thành công.");
      } catch (e) {
        debugPrint("⚠️ [Router] Lỗi Switch Store: $e");
        TSnackbarsWidget.error(
            title: 'Lỗi', message: 'Không thể truy cập cửa hàng.');
        if (isFromSplash) Get.offAllNamed(AppRoutes.main);
        return;
      }
    }

    if (didSwitchStore || isFromSplash) {
      // Lúc này Get.currentRoute đang là màn hình Loading, lệnh offAllNamed sẽ chạy hoàn hảo 100%
      Get.offAllNamed(AppRoutes.main);

      // Đợi MainScreen build xong các Tab và Controller (Tăng thời gian an toàn)
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _performFinalNavigation(type, referenceId, supabase);
  }

  static Future<void> _performFinalNavigation(
      String type, String? referenceId, SupabaseClient? supabase) async {
    debugPrint("🎯 [Router] Đang nhảy vào màn chi tiết: $type");

    switch (type) {
      // 1. Nhóm cảnh báo sắp hết hàng (UC-NA-01)
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

      // 2. Nhóm gợi ý nhập hàng (UC-NA-02 & UC-SDS-01) - MỚI THÊM
      case 'REORDER_SUGGESTION':
      case 'REORDER_REQUIRED':
        if (referenceId != null && referenceId.isNotEmpty) {
          // Có thể truyền thêm tham số báo cho màn hình Detail biết cần bật Popup gợi ý nhập hàng
          Get.toNamed(AppRoutes.inventoryDetail,
              arguments: referenceId, parameters: {'action': 'reorder'});
        } else {
          Get.toNamed(AppRoutes.lowStock);
        }
        break;

      // 3. Nhóm Giao dịch (UC-ST-01 -> UC-ST-04)
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

      // 4. Nhóm Cảnh báo lệch kho
      case 'DISCREPANCY_ALERT':
      case 'ADJUSTMENT':
        if (referenceId != null && referenceId.isNotEmpty) {
          final searchQuery = '[Lô-$referenceId]';

          Get.toNamed(
            AppRoutes.adjustmentHistory,
            arguments: {'batchId': searchQuery},
          );
        } else {
          Get.toNamed(AppRoutes.transactionSummary);
        }
        break;

      case 'ROLE_UPDATED':
        TSnackbarsWidget.warning(
            title: 'Phiên đăng nhập hết hạn',
            message:
                'Quyền hạn của bạn đã bị thay đổi, vui lòng đăng nhập lại.');

        await supabase!.auth.signOut();
        // Đăng xuất Google để lần sau hiện lại popup chọn tài khoản
        await GoogleSignIn.instance.signOut();

        // 2. Xoá StoreID hoặc data local
        GetStorage().remove('STORE_ID');

        // 3. Điều hướng về màn Login
        Get.offAllNamed(AppRoutes.login);
        break;

      default:
        if (Get.currentRoute != AppRoutes.notification) {
          Get.toNamed(AppRoutes.notification);
        }
        break;
    }
  }
}
