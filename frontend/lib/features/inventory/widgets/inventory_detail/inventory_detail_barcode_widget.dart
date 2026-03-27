import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailBarcodeWidget extends GetView<InventoryDetailController> {
  const InventoryDetailBarcodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final type = controller.barcodeType.toUpperCase();
    final isQR = type.contains('QR');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider)),
              child: isQR
                  ? _buildMockQRCode()
                  : _buildMockLinearBarcode(controller.barcode),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                          isQR
                              ? Iconsax.scan_barcode_copy
                              : Iconsax.barcode_copy,
                          size: 14,
                          color: AppColors.subText),
                      const SizedBox(width: 4),
                      Text("${TTexts.barcodeType.tr}: $type",
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subText,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(controller.barcode,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          fontFamily: 'Poppins',
                          color: AppColors.primaryText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thuật toán vẽ vạch đen trắng ngẫu nhiên dựa trên chuỗi SKU
  Widget _buildMockLinearBarcode(String value) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: value.padRight(10, '0').split('').take(15).map((char) {
          int widthMultiplier = (char.codeUnitAt(0) % 3) + 1;
          return Container(
            width: widthMultiplier * 1.5,
            color: Colors.black,
            margin: const EdgeInsets.only(right: 1.5),
          );
        }).toList(),
      ),
    );
  }

  // Thuật toán vẽ mã QR cơ bản
  Widget _buildMockQRCode() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          Container(color: Colors.black),
          Positioned(
              top: 4,
              left: 4,
              child: Container(
                  width: 12,
                  height: 12,
                  color: Colors.white,
                  child: Center(
                      child: Container(
                          width: 6, height: 6, color: Colors.black)))),
          Positioned(
              top: 4,
              right: 4,
              child: Container(
                  width: 12,
                  height: 12,
                  color: Colors.white,
                  child: Center(
                      child: Container(
                          width: 6, height: 6, color: Colors.black)))),
          Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                  width: 12,
                  height: 12,
                  color: Colors.white,
                  child: Center(
                      child: Container(
                          width: 6, height: 6, color: Colors.black)))),
          Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                  width: 16,
                  height: 16,
                  color: Colors.white,
                  child: const Icon(Icons.qr_code,
                      size: 16, color: Colors.black))),
        ],
      ),
    );
  }
}
