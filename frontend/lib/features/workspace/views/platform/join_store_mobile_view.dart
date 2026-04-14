// lib/features/workspace/views/join_store/join_store_mobile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/workspace/widgets/join_store/join_store_header_widget.dart';
import 'package:frontend/features/workspace/widgets/join_store/join_store_input_field_widget.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/workspace/controllers/join_store_controller.dart';

class JoinStoreMobileView extends GetView<JoinStoreController> {
  const JoinStoreMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,

        // Header Component chung
        appBar: const TBlurAppBarWidget(),

        // BODY
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.p16),

                // 1. TIÊU ĐỀ
                const JoinStoreHeaderWidget(),

                const SizedBox(height: AppSizes.p48),

                // 2. Ô NHẬP MÃ 6 KÝ TỰ
                const JoinStoreInputFieldWidget(),

                const SizedBox(height: AppSizes.p48),

                // 3. NÚT SUBMIT
                Obx(() => TPrimaryButtonWidget(
                      text: controller.isLoading.value
                          ? TTexts.joiningBtn.tr
                          : TTexts.joinBtn.tr,
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.onJoinWorkspace,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
