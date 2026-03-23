// lib/features/workspace/views/platform/workspace_ready_mobile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_image_widget.dart';
import 'package:frontend/features/workspace/widgets/workspace_ready/workspace_ready_actions_widget.dart';

class WorkspaceReadyMobileView extends StatelessWidget {
  const WorkspaceReadyMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final storeName = args['storeName'] ?? 'Your Workspace';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // 1. ẢNH & TIÊU ĐỀ
                  TImageWidget(
                    image: TImages.coreImages.successAdding,
                    width: MediaQuery.of(context).size.width * 0.65,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSizes.p32),
                  Text(
                    TTexts.workspaceCreatedTitle.tr,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Text(
                    "'$storeName' ${TTexts.workspaceCreatedDesc.tr}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: AppColors.subText,
                        height: 1.5),
                  ),
                  const SizedBox(height: AppSizes.p32),

                  // 2. BADGE MANAGER
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p20, vertical: AppSizes.p12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondPrimary],
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 24),
                        const SizedBox(width: AppSizes.p8),
                        Text(
                          TTexts.youAreManager.tr,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 3. ACTIONS (Gọi widget đã tách)
                  const WorkspaceReadyActionsWidget(),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
