import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class ReportTransactionDetailItemCardWidget extends StatelessWidget {
  final TransactionDetailModel item;

  const ReportTransactionDetailItemCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final priceStr = NumberFormat.currency(locale: 'en_US', symbol: '\$')
        .format(item.unitPrice);

    final String? imageUrl = item.packageInfo?.product?.imageUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (item.productPackageId != null &&
                item.productPackageId!.isNotEmpty) {
              Get.toNamed(
                AppRoutes.inventoryDetail,
                arguments: item.productPackageId,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // --- PRODUCT IMAGE ---
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.softGrey.withOpacity(0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                                Iconsax.box_1_copy,
                                color: AppColors.softGrey,
                                size: 24),
                          )
                        : const Icon(Iconsax.box_1_copy,
                            color: AppColors.softGrey, size: 24),
                  ),
                ),
                const SizedBox(width: 16),

                // --- PRODUCT INFO ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.packageInfo?.displayName ?? 'Unknown Product',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                          'Barcode: ${item.packageInfo?.barcodeValue ?? "N/A"}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.subText)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(priceStr,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('x${item.quantity}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
