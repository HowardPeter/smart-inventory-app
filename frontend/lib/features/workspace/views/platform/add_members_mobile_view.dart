// lib/features/workspace/views/add_members/add_members_mobile_view.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart'; // Thêm dòng này
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart'; // Thêm dòng này
import 'package:frontend/features/workspace/controllers/add_members_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

import '../../widgets/add_members/add_members_header_widget.dart';
import '../../widgets/add_members/add_members_invite_code_widget.dart';
import '../../widgets/add_members/add_members_list_widget.dart';

class AddMembersMobileView extends GetView<AddMembersController> {
  const AddMembersMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddMembersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TBlurAppBarWidget(),
      body: SafeArea(
        child: Obx(() {
          // 1. TRẠNG THÁI LOADING LẦN ĐẦU -> SHIMMER TOÀN TRANG
          if (controller.isInitialLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.p24),
              child: TFormSkeletonWidget(
                  itemCount: 6), // Hiện 6 khung mờ giả lập toàn trang
            );
          }

          // 2. TRẠNG THÁI BÌNH THƯỜNG CÓ KÉO THẢ REFRESH
          return TRefreshIndicatorWidget(
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  const AddMembersHeaderWidget(),
                  const SizedBox(height: AppSizes.p32),

                  // PHÂN QUYỀN: CHỈ OWNER VÀ MANAGER MỚI THẤY KHU VỰC TẠO MÃ
                  if (controller.canManageWorkspace) ...[
                    const AddMembersInviteCodeWidget(),
                    const SizedBox(height: AppSizes.p16),
                    const Divider(
                        height: 32, thickness: 1, color: AppColors.softGrey),
                  ],

                  // MEMBERS COUNT
                  Text(
                    "${TTexts.membersCount.tr} (${controller.members.length})",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText),
                  ),
                  const SizedBox(height: AppSizes.p12),

                  // MEMBERS LIST
                  const AddMembersListWidget(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
