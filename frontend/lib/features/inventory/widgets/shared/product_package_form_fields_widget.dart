import 'package:flutter/material.dart';
import 'package:frontend/features/inventory/widgets/shared/product_package_unit_dropdown_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';

class ProductPackageFormFieldsWidget extends GetView<ProductFormController> {
  const ProductPackageFormFieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.packageFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CHỌN ĐƠN VỊ
          const ProductPackageUnitDropdownWidget(),
          const SizedBox(height: 24),

          // 2. TÊN PHÂN LOẠI
          TTextFormFieldWidget(
            label: TTexts.variantNameLabel.tr,
            hintText: TTexts.variantNameHint.tr,
            controller: controller.packageDisplayNameController,
            validator: (v) =>
                (v == null || v.isEmpty) ? TTexts.errorUnknownMessage.tr : null,
          ),
          const SizedBox(height: 24),

          // 3. GIÁ NHẬP & GIÁ BÁN (ĐƯỢC BỌC TRONG ROW AN TOÀN)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TTextFormFieldWidget(
                  label: TTexts.importCost.tr,
                  hintText: TTexts.zeroPointZero.tr,
                  keyboardType: TextInputType.number,
                  controller: controller.importPriceController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TTextFormFieldWidget(
                  label: TTexts.salePrice.tr,
                  hintText: TTexts.zeroPointZero.tr,
                  keyboardType: TextInputType.number,
                  controller: controller.salePriceController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. MỨC CẢNH BÁO & BARCODE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TTextFormFieldWidget(
                  label: TTexts.reorderThresholdLabel.tr,
                  hintText: TTexts.reorderThresholdHint.tr,
                  keyboardType: TextInputType.number,
                  controller: controller.thresholdController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: TTextFormFieldWidget(
                  label: TTexts.barcodeLabel.tr,
                  hintText: TTexts.scanOrTypeBarcode.tr,
                  controller: controller.barcodeController,
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.scan_barcode_copy,
                        color: AppColors.primary),
                    onPressed: () {
                      Get.to(() => TBarcodeScannerLayout(
                            title: TTexts.homeScanBarcode.tr,
                            onScanned: (code) {
                              controller.barcodeController.text = code;
                              Get.back();
                            },
                          ));
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
