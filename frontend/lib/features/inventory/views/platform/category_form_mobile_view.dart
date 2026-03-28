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
        // Tiêu đề động
        title: controller.isEditMode
            ? TTexts.editCategoryTitle.tr
            : TTexts.addNewCategory.tr,
        showBackArrow: true,
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.p20),
          decoration: BoxDecoration(color: AppColors.white, boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4))
          ]),
          child: TPrimaryButtonWidget(
            text: TTexts.saveCategory.tr,
            onPressed: () => controller.saveCategory(),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  validator: (value) => (value == null || value.trim().isEmpty)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
