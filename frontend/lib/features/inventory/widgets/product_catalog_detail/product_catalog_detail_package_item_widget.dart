import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductCatalogDetailPackageItemWidget extends StatelessWidget {
  final ProductPackageModel package;
  final VoidCallback onEdit;

  const ProductCatalogDetailPackageItemWidget({
    super.key,
    required this.package,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  package.displayName,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText),
                ),
              ),
              // Nút Menu/Edit cho Package
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Iconsax.edit_2_copy,
                    color: AppColors.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p12),

          // Mã vạch
          Row(
            children: [
              const Icon(Iconsax.barcode_copy,
                  size: 16, color: AppColors.softGrey),
              const SizedBox(width: 6),
              Text(
                package.barcodeValue?.isNotEmpty == true
                    ? package.barcodeValue!
                    : TTexts.noBarcode.tr,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.subText),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Giá bán & Giá nhập
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceItem(
                  TTexts.importCost.tr, package.importPrice, AppColors.subText),
              _buildPriceItem(
                  TTexts.salePrice.tr, package.sellingPrice, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, double price, Color priceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.softGrey)),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: priceColor),
        ),
      ],
    );
  }
}
