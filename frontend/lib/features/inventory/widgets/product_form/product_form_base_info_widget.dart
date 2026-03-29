import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductFormBaseInfoWidget extends GetView<ProductFormController> {
  const ProductFormBaseInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.baseFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Ô CHỌN DANH MỤC
          GestureDetector(
            // Logic KHÓA: Nếu isCategoryLocked = true thì onTap = null (không bấm được)
            onTap: controller.isCategoryLocked
                ? null
                : () => controller.openCategoryPicker(),
            child: AbsorbPointer(
              child: Obx(() => TTextFormFieldWidget(
                    label: TTexts.selectCategory.tr,
                    hintText: controller.selectedCategory.value?.name ??
                        TTexts.tapToSelect.tr,
                    // Logic ĐỔI ICON: Khóa thì hiện ổ khóa, mở thì hiện mũi tên
                    suffixIcon: controller.isCategoryLocked
                        ? const Icon(Iconsax.lock_copy,
                            size: 18, color: AppColors.softGrey)
                        : const Icon(Iconsax.arrow_down_1_copy, size: 20),
                    controller: TextEditingController(
                        text: controller.selectedCategory.value?.name ?? ''),
                  )),
            ),
          ),
          const SizedBox(height: 24),

          TTextFormFieldWidget(
              label: TTexts.productNameLabel.tr,
              hintText: TTexts.productNameSubLabel.tr,
              controller: controller.nameController,
              validator: (v) => (v == null || v.isEmpty)
                  ? TTexts.errorUnknownMessage.tr
                  : null),
          const SizedBox(height: 24),

          TTextFormFieldWidget(
              label: TTexts.brand.tr,
              hintText: TTexts.brandSub.tr,
              controller: controller.brandController),
        ],
      ),
    );
  }
}
