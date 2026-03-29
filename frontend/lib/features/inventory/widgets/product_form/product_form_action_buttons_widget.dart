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
        // NÚT TRONG CHẾ ĐỘ SỬA
        if (controller.isEditMode) {
          return TPrimaryButtonWidget(
              text: TTexts.saveCategory.tr,
              onPressed: () => controller.saveProduct());
        }

        final step = controller.currentStep.value;

        // BƯỚC 1: TIẾP THEO (Tên SP -> Ảnh)
        if (step == 1) {
          return TPrimaryButtonWidget(
              text: TTexts.nextStep.tr, onPressed: () => controller.nextStep());
        }

        // BƯỚC 2: QUAY LẠI & TIẾP THEO (Ảnh -> Gói Hàng)
        else if (step == 2) {
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
                      onPressed: () =>
                          controller.nextStep())), // Ở BƯỚC 2 CHỈ LÀ NEXT THÔI
            ],
          );
        }

        // BƯỚC 3: QUAY LẠI & TẠO MỚI (Gói hàng -> Gọi API)
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
                    onPressed: () => controller
                        .saveProduct())), // TỚI BƯỚC 3 MỚI ĐƯỢC CREATE
          ],
        );
      }),
    );
  }
}
