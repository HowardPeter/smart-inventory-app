import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/features/profile/controllers/profile_assigns_role_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'assigns_role_item_widgets.dart';

class AssignsRoleListWidget extends StatelessWidget {
  const AssignsRoleListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileAssignsRoleController>();

    return Obx(() {
      // 1. Trạng thái đang tải dữ liệu
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      // 2. Trạng thái KHÔNG tìm thấy kết quả
      if (controller.filteredUsers.isEmpty) {
        return const TEmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No results found',
          subtitle: 'We couldn\'t find any users matching your search.',
        );
      }

      // 3. Trạng thái hiển thị danh sách bình thường
      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredUsers.length,
        itemBuilder: (context, index) {
          final user = controller.filteredUsers[index];
          return AssignsRoleItemWidget(
            name: user['name'] ?? '',
            role: user['role'] ?? '',
            image: user['image'] ?? '',
            onRoleChanged: (newRole) =>
                controller.updateRole(user['id'], newRole),
          );
        },
      );
    });
  }
}
