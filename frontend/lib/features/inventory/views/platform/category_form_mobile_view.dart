import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/inventory/controllers/category_form_controller.dart';

class CategoryFormMobileView extends GetView<CategoryFormController> {
  const CategoryFormMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TAppBarWidget(
        title: controller.isEditMode
            ? TTexts.editCategoryTitle.tr
            : TTexts.addNewCategory.tr,
        showBackArrow: true,
        centerTitle: true,
      ),
      // ĐÃ BỎ BOTTOM NAVIGATION BAR

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.p12),
                  TTextFormFieldWidget(
                    label: TTexts.categoryNameLabel.tr,
                    hintText: TTexts.categoryNameHint.tr,
                    controller: controller.nameController,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? TTexts.categoryNameRequired.tr
                            : null,
                  ),
                  const SizedBox(height: AppSizes.p24),
                  TTextFormFieldWidget(
                    label: TTexts.categoryDescLabel.tr,
                    hintText: TTexts.categoryDescHint.tr,
                    controller: controller.descController,
                    maxLines: 4,
                  ),

                  // Khoảng cách đẩy nút bấm xuống dưới cùng cho đẹp
                  const SizedBox(height: 48),

                  // ĐÃ CHUYỂN NÚT BẤM VÀO TRONG BODY (Giống Product Form)
                  TPrimaryButtonWidget(
                    text: TTexts.saveCategory.tr,
                    onPressed: () => controller.saveCategory(),
                  ),

                  // Khoảng đệm đáy để cuộn không bị sát lề
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
