import 'package:flutter/material.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_package_unit_dropdown_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';

class InventoryProductPackageFormFieldsWidget
    extends GetView<ProductFormController> {
  const InventoryProductPackageFormFieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.packageFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CHỌN ĐƠN VỊ
          const InventoryProductPackageUnitDropdownWidget(),
          const SizedBox(height: 24),

          // 2. TÊN PHÂN LOẠI
          TTextFormFieldWidget(
            label: TTexts.variantNameLabel.tr,
            hintText: TTexts.variantNameHint.tr,
            isRequired: true,
            controller: controller.packageDisplayNameController,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? TTexts.fieldRequired.tr
                : null,
          ),

          // --- DANH SÁCH CHIPS CUỘN NGANG ---
          Obx(() {
            final suggestions = controller.variantNameSuggestions;
            if (suggestions.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Cuộn ngang
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: suggestions
                      .map((suggestion) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(suggestion,
                                  style: const TextStyle(
                                      fontSize: 12, fontFamily: 'Poppins')),
                              backgroundColor: AppColors.surface,
                              side: BorderSide(
                                  color: AppColors.primary.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onPressed: () => controller
                                  .selectVariantSuggestion(suggestion),
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // 3. GIÁ NHẬP & GIÁ BÁN
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TTextFormFieldWidget(
                  label: TTexts.importCost.tr,
                  hintText: TTexts.zeroPointZero.tr,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  controller: controller.importPriceController,
                  validator: (v) {
                    // 1. Không được để trống
                    if (v == null || v.trim().isEmpty) {
                      return TTexts.fieldRequired.tr;
                    }

                    // 2. Phải là số hợp lệ
                    final price = double.tryParse(v.trim());
                    if (price == null) return TTexts.invalidNumber.tr;

                    // 3. Phải lớn hơn 0
                    if (price < 0) return TTexts.priceGreaterThanZero.tr;

                    return null; // Hợp lệ
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TTextFormFieldWidget(
                  label: TTexts.salePrice.tr,
                  hintText: TTexts.zeroPointZero.tr,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  controller: controller.salePriceController,
                  validator: (v) {
                    // 1. Không được để trống
                    if (v == null || v.trim().isEmpty) {
                      return TTexts.fieldRequired.tr;
                    }

                    // 2. Phải là số hợp lệ
                    final price = double.tryParse(v.trim());
                    if (price == null) return TTexts.invalidNumber.tr;

                    // 3. Phải lớn hơn 0
                    if (price < 0) return TTexts.priceGreaterThanZero.tr;

                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. MỨC CẢNH BÁO
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: TTextFormFieldWidget(
                  label: TTexts.reorderThresholdLabel.tr,
                  hintText: TTexts.zero.tr,
                  keyboardType: TextInputType.number,
                  controller: controller.thresholdController,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
                      return TTexts.invalidNumber.tr;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Tooltip(
                  message: TTexts.zeroMeansNoLimit.tr,
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: false,
                  decoration: BoxDecoration(
                    color: AppColors.primaryText.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontSize: 12),
                  child: const Icon(Iconsax.info_circle_copy,
                      color: AppColors.softGrey, size: 22),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 24),

          // 5. BARCODE
          TTextFormFieldWidget(
            label: TTexts.barcodeLabel.tr,
            hintText: TTexts.scanOrTypeBarcode.tr,
            controller: controller.barcodeController,
            isRequired: true,
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
        ],
      ),
    );
  }
}
