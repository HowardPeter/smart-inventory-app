import 'package:flutter/material.dart';
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
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      return ListView.builder(
        shrinkWrap: true,
        // Xóa sạch padding của ListView để sát với dòng "results found"
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
