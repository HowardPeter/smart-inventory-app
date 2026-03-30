import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';

class ProductFormActionButtonsWidget extends GetView<ProductFormController> {
  const ProductFormActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSizes.p20, right: AppSizes.p20, bottom: 48, top: 16),
      child: Obx(() {
        final mode = controller.formMode.value;
        final step = controller.currentStep.value;

        // 1. CÁC NÚT BẤM DÀNH CHO CHẾ ĐỘ CHỈNH SỬA (LẺ TẺ)
        if (mode == 'info') {
          return TPrimaryButtonWidget(
              text: TTexts.saveChanges.tr,
              onPressed: () => controller.saveProductInfo());
        }
        if (mode == 'image') {
          return TPrimaryButtonWidget(
              text: TTexts.saveImage.tr,
              onPressed: () => controller.saveProductImage());
        }
        if (mode == 'edit_package') {
          return TPrimaryButtonWidget(
              text: TTexts.savePackage.tr,
              onPressed: () => controller.savePackageData());
        }
        if (mode == 'add_package') {
          return TPrimaryButtonWidget(
              text: TTexts.addPackageBtn.tr,
              onPressed: () => controller.savePackageData());
        }

        // 2. CÁC NÚT BẤM DÀNH CHO WIZARD TẠO MỚI HOÀN TOÀN (CREATE)
        if (step == 1) {
          return TPrimaryButtonWidget(
              text: TTexts.nextStep.tr, onPressed: () => controller.nextStep());
        } else if (step == 2) {
          return Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TPrimaryButtonWidget(
                      text: TTexts.previousStep.tr,
                      isOutlined: true,
                      textColor: AppColors.primaryText,
                      onPressed: () => controller.previousStep())),
              const SizedBox(width: 16),
              Expanded(
                  flex: 2,
                  child: TPrimaryButtonWidget(
                      text: TTexts.nextStep.tr,
                      onPressed: () => controller.nextStep())),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TPrimaryButtonWidget(
                      text: TTexts.previousStep.tr,
                      isOutlined: true,
                      textColor: AppColors.primaryText,
                      onPressed: () => controller.previousStep())),
              const SizedBox(width: 16),
              Expanded(
                  flex: 2,
                  child: TPrimaryButtonWidget(
                      text: TTexts.create.tr,
                      onPressed: () => controller.saveProduct())),
            ],
          );
        }
      }),
    );
  }
}
