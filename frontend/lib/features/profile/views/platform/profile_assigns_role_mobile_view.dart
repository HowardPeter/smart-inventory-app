import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:frontend/features/profile/controllers/profile_assigns_role_controller.dart';
import 'package:frontend/features/profile/widgets/assigns_role/assigns_role_list_widgets.dart';
import 'package:frontend/features/profile/widgets/assigns_role/assigns_role_search_widgets.dart';
import 'package:frontend/features/profile/widgets/assigns_role/assigns_role_tab_widgets.dart';
import 'package:get/get.dart';

class AssignsRoleMobileView extends StatelessWidget {
  const AssignsRoleMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controller tại đây
    final controller = Get.put(ProfileAssignsRoleController());

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: const TBlurAppBarWidget(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                kToolbarHeight +
                AppSizes.p16,
            left: AppSizes.p24,
            right: AppSizes.p24,
            bottom: AppSizes.p48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER
              Text(TTexts.assignsRoleTitle.tr,
                  style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 28,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: AppSizes.p4),
              Text(TTexts.assignsRoleSubtitle.tr,
                  style:
                      const TextStyle(color: AppColors.subText, fontSize: 16)),

              const SizedBox(height: AppSizes.p24),

              // 2. SEARCH BAR
              AssignsRoleSearchWidget(
                hintText: TTexts.assignsRoleSearchHint.tr,
                onTap: () {},
              ),

              const SizedBox(height: AppSizes.p20),

              // 3. TABS
              const AssignsRoleTabWidget(),

              const SizedBox(height: AppSizes.p20),

              // 4. HIỂN THỊ SỐ LƯỢNG
              Obx(() => Row(
                    children: [
                      Text("${controller.totalCount} ",
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Text("results found",
                          style: TextStyle(
                              color: AppColors.subText, fontSize: 14)),
                    ],
                  )),

              const SizedBox(height: AppSizes.p12),

              // 5. DANH SÁCH ROLE
              const AssignsRoleListWidget(),

              const SizedBox(height: 40),
              const TBottomNavSpacerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
