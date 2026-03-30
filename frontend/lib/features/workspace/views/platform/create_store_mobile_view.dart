import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/workspace/controllers/create_store_controller.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/features/workspace/widgets/create_store/create_store_input_form_widget.dart';
import 'package:frontend/features/workspace/widgets/create_store/create_store_map_preview_widget.dart';

class CreateStoreMobileView extends GetView<CreateStoreController> {
  const CreateStoreMobileView({super.key});

  @override
  Widget build(BuildContext context) {
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
              // HEADER TITLE
              Text(
                TTexts.createStoreTitle.tr,
                style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 28,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                TTexts.createStoreSubtitle.tr,
                style: const TextStyle(
                    color: AppColors.subText, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: AppSizes.p32),

              // FORM NHẬP LIỆU & GPS
              const CreateStoreInputFormWidget(),
              const SizedBox(height: AppSizes.p24),

              // BẢN ĐỒ
              const CreateStoreMapPreviewWidget(),
              const SizedBox(height: AppSizes.p48),

              // NÚT SUBMIT
              Obx(() => TPrimaryButtonWidget(
                    text: controller.isLoading.value
                        ? TTexts.creatingYourWorkspace.tr
                        : TTexts.createYourWorkspace.tr,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.onTryCreateWorkspace,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
