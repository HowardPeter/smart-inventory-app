import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/features/workspace/controllers/add_members_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

// Import các sub-widgets
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER TITLE & SUBTITLE
              const AddMembersHeaderWidget(),
              const SizedBox(height: AppSizes.p32),

              // 2. INVITE CODE SECTION
              const AddMembersInviteCodeWidget(),
              const SizedBox(height: AppSizes.p16),

              const Divider(
                  height: 32, thickness: 1, color: AppColors.softGrey),

              // 3. MEMBERS COUNT
              Obx(() => Text(
                    "${TTexts.membersCount.tr} (${controller.members.length})",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText),
                  )),
              const SizedBox(height: AppSizes.p8),

              // 4. MEMBERS LIST (Xử lý Loading/Empty State bên trong)
              const AddMembersListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
