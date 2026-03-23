import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

// THÊM 2 IMPORTS NÀY VÀO ĐỂ LẤY DATA VÀ CHUYỂN TRANG
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/routes/app_routes.dart';

class ProfileMobileView extends GetView<ProfileController> {
  const ProfileMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Gọi StoreService ra để lấy thông tin cửa hàng hiện tại
    final storeService = Get.find<StoreService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
              color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Avatar Demo
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // 2. Tiêu đề mục: Thông tin người dùng
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
            ),
            const SizedBox(height: AppSizes.p12),

            // 3. Hiển thị thông tin lấy từ RAM (UserService)
            Obx(() {
              final user = controller.userService.currentUser.value;

              if (user == null) {
                return const Center(child: Text('Không có dữ liệu người dùng'));
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Họ và tên', user.fullName),
                      const Divider(),
                      _buildInfoRow('Email', user.email),
                      const Divider(),
                      _buildInfoRow('ID Người dùng', user.userId),
                      const Divider(),
                      _buildInfoRow(
                          'Trạng thái', user.activeStatus.toUpperCase()),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSizes.p24),

            // 4. Tiêu đề mục: Thông tin Cửa hàng
            const Text(
              'Không gian làm việc (Workspace)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
            ),
            const SizedBox(height: AppSizes.p12),

            // 5. Hiển thị thông tin lấy từ StoreService
            Obx(() {
              final storeId = storeService.currentStoreId.value;
              final storeName = storeService.currentStoreName.value;

              if (storeId.isEmpty) {
                return const Center(child: Text('Chưa chọn cửa hàng nào'));
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Tên cửa hàng', storeName),
                      const Divider(),
                      _buildInfoRow('ID Cửa hàng', storeId),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSizes.p32),

            // 6. Nút: Đổi cửa hàng (Quay lại màn Store Selection)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Dùng offAllNamed để xóa lịch sử trang và reset lại trạng thái về màn chọn
                  Get.offAllNamed(AppRoutes.storeSelection);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                icon: const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.primary),
                label: const Text(
                  'Đổi không gian làm việc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.p16),

            // 7. Nút: Đăng xuất
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.executeLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Khoảng trống chống lấp bởi Bottom Navigation Bar
            const TBottomNavSpacerWidget(),
          ],
        ),
      ),
    );
  }

  // Widget helper để vẽ các dòng thông tin cho gọn code
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
