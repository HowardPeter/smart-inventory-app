import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ProfileMobileView extends GetView<ProfileController> {
  const ProfileMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Dùng cuộn để chứa spacer ở đáy
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Demo
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: AppSizes.p24),

            // Hiển thị thông tin lấy từ RAM (UserService)
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

            const SizedBox(height: AppSizes.p32),

            // Nút Đăng xuất
            ElevatedButton.icon(
              onPressed: controller.executeLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),

            // Khoảng trống chống lấp bởi Bottom Navigation Bar
            const TBottomNavSpacer(),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
