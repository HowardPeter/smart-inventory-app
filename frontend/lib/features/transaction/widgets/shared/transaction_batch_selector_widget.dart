import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionBatchSelectorWidget extends StatelessWidget {
  final List<TransactionModel> inboundTransactions;
  final Map<String, int> selectedBatchesQty;
  final Function(String batchId, int newQty, int maxStock) onUpdateQty;
  final String currentPackageId;

  const TransactionBatchSelectorWidget({
    super.key,
    required this.inboundTransactions,
    required this.selectedBatchesQty,
    required this.onUpdateQty,
    required this.currentPackageId,
  });

  @override
  Widget build(BuildContext context) {
    if (inboundTransactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 8),
          child: Text(
            TTexts.selectBatchFIFO.tr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600, // Nhẹ hơn bold
              color: AppColors.primaryText,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 380),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: inboundTransactions.length,
            itemBuilder: (context, index) {
              final tx = inboundTransactions[index];
              final txId = tx.transactionId!;
              final dateStr = tx.createdAt != null
                  ? DateFormat('dd/MM/yyyy').format(tx.createdAt!)
                  : '--/--/----';

              final detail = tx.items.firstWhereOrNull(
                  (i) => i.productPackageId == currentPackageId);
              final maxStock = detail?.quantity ?? 0;
              final isOutOfStock = maxStock <= 0;

              final currentQty = selectedBatchesQty[txId] ?? 0;
              final isSelected = currentQty > 0;

              return GestureDetector(
                onTap: isOutOfStock
                    ? null
                    : () {
                        if (currentQty == 0) onUpdateQty(txId, 1, maxStock);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p20, vertical: 6),
                  padding: const EdgeInsets.all(16), // Tăng padding cho thoáng
                  decoration: BoxDecoration(
                    // Nền nhạt và viền mỏng 1px
                    color: isSelected
                        ? AppColors.secondPrimary.withOpacity(0.02)
                        : (isOutOfStock ? AppColors.surface : Colors.white),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.5)
                          : Colors.grey.shade200,
                      width: 1.0, // Viền mỏng
                    ),
                    borderRadius: BorderRadius.circular(12), // Bo góc vừa phải
                  ),
                  child: Opacity(
                    opacity: isOutOfStock ? 0.5 : 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // CỤM TRÁI (THÔNG TIN LÔ)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Import: #${txId.substring(txId.length - 6).toUpperCase()}",
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w500, // Chữ thanh mảnh hơn
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    color: AppColors.primaryText,
                                  )),
                              const SizedBox(height: 4),
                              Text('${TTexts.importedOn.tr}: $dateStr',
                                  style: const TextStyle(
                                    color: AppColors.softGrey,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  )),
                            ],
                          ),
                        ),

                        // CỤM PHẢI (TỒN KHO & NÚT +/-)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                isOutOfStock
                                    ? TTexts.outOfStockBatch.tr
                                    : '$maxStock ${TTexts.batchRemaining.tr}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500, // Chữ thanh mảnh
                                  fontSize: 12,
                                  color: isOutOfStock
                                      ? AppColors.alertText
                                      : AppColors.softGrey,
                                  fontFamily: 'Poppins',
                                )),
                            const SizedBox(height: 10),
                            if (!isOutOfStock)
                              Row(
                                children: [
                                  // Nút Trừ
                                  _buildOutlineButton(
                                    icon: Iconsax.minus_copy,
                                    onTap: currentQty > 0
                                        ? () => onUpdateQty(
                                            txId, currentQty - 1, maxStock)
                                        : null,
                                    disabled: currentQty <= 0,
                                  ),

                                  // Số lượng
                                  SizedBox(
                                    width: 36,
                                    child: Center(
                                      child: Text(
                                        '$currentQty',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          fontSize: 14,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.primaryText,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Nút Cộng
                                  _buildOutlineButton(
                                    icon: Iconsax.add_copy,
                                    onTap: currentQty < maxStock
                                        ? () => onUpdateQty(
                                            txId, currentQty + 1, maxStock)
                                        : null,
                                    disabled: currentQty >= maxStock,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
              vertical: AppSizes.p16, horizontal: AppSizes.p20),
          child: Divider(
              color: AppColors.divider,
              height: 1,
              thickness: 0.5), // Đường kẻ nhạt
        ),
      ],
    );
  }

  // WIDGET NÚT TĂNG GIẢM DẠNG VIỀN MẢNH (OUTLINE)
  Widget _buildOutlineButton(
      {required IconData icon, VoidCallback? onTap, bool disabled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: disabled ? AppColors.surface : Colors.white,
          border: Border.all(
            color: disabled ? Colors.transparent : Colors.grey.shade300,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? Colors.grey.shade400 : AppColors.primaryText,
        ),
      ),
    );
  }
}
