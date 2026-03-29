import 'package:flutter/material.dart';
import 'package:frontend/features/inventory/widgets/shared/product_package_form_fields_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:frontend/features/inventory/widgets/product_form/product_form_progress_bar_widget.dart';
import 'package:frontend/features/inventory/widgets/product_form/product_form_base_info_widget.dart';
import 'package:frontend/features/inventory/widgets/product_form/product_form_image_widget.dart';
import 'package:frontend/features/inventory/widgets/product_form/product_form_action_buttons_widget.dart';

class ProductFormMobileView extends GetView<ProductFormController> {
  const ProductFormMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Tự động được gọi khi người dùng bấm nút Back trên AppBar hoặc vuốt thoát
        controller.confirmExit();
        return false; // Trả về false để chặn việc thoát ngang
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: TAppBarWidget(
          title: controller.isEditMode
              ? TTexts.editProductTitle.tr
              : TTexts.addNewProductTitle.tr,
          centerTitle: true,
          showBackArrow: true,
          onBackPress: () => controller.confirmExit(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. THANH TIẾN TRÌNH MINIMALIST (Chỉ hiện khi Add)
                if (!controller.isEditMode)
                  const ProductFormProgressBarWidget(),

                // 2. KHU VỰC NHẬP LIỆU CHÍNH
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.p20,
                      vertical:
                          controller.isEditMode ? AppSizes.p24 : AppSizes.p12),
                  child: Obx(() {
                    final step = controller.currentStep.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==========================================
                        // TITLE & SUBTITLE ĐỘNG THEO TỪNG BƯỚC
                        // ==========================================
                        if (!controller.isEditMode) ...[
                          Text(
                            step == 1
                                ? TTexts.productBaseTitle.tr
                                : (step == 2
                                    ? TTexts.productImageTitle.tr
                                    : TTexts.productPackageTitle.tr),
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step == 1
                                ? TTexts.productBaseSub.tr
                                : (step == 2
                                    ? TTexts.productImageSub.tr
                                    : TTexts.productPackageSub.tr),
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.subText,
                                height: 1.4),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // ==========================================
                        // ANIMATED SWITCHER CHUYỂN FORM SIÊU MƯỢT
                        // ==========================================
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            final inAnimation = Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero)
                                .animate(animation);
                            return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                    position: inAnimation, child: child));
                          },
                          child: _renderCurrentForm(step),
                        ),
                      ],
                    );
                  }),
                ),

                // 3. KHU VỰC NÚT BẤM
                const ProductFormActionButtonsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HÀM RENDER FORM DỰA VÀO STEP
  Widget _renderCurrentForm(int step) {
    if (controller.isEditMode) {
      return const ProductFormBaseInfoWidget(key: ValueKey('editBase'));
    }

    if (step == 1) {
      return const ProductFormBaseInfoWidget(key: ValueKey('stepBase'));
    }
    if (step == 2) {
      return const ProductFormImageWidget(key: ValueKey('stepImage'));
    }

    // Bước 3: Package Pricing
    return const Form(
        key: ValueKey('stepPackage'), child: ProductPackageFormFieldsWidget());
  }
}
