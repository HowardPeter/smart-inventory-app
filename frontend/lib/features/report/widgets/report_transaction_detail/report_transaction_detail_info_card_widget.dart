import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportTransactionDetailInfoCardWidget extends StatelessWidget {
  final TransactionModel tx;

  const ReportTransactionDetailInfoCardWidget({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    // 🟢 LẤY THÔNG TIN REAL TỪ SERVICES
    final userService = Get.find<UserService>();
    final storeService = Get.find<StoreService>();

    final String userName =
        userService.currentUser.value?.fullName ?? 'Unknown User';
    final String authUserId =
        userService.currentUser.value?.authUserId ?? tx.userId ?? 'default';

    // 🟢 FORMAT ROLE: "owner" -> "Owner", "manager" -> "Manager", "staff" -> "Staff"
    final String displayRole =
        storeService.currentRole.value.capitalizeFirst ?? 'Staff';
    final String storeName = storeService.currentStoreName.value.isNotEmpty
        ? storeService.currentStoreName.value
        : 'Main HQ Store';

    Color typeColor = AppColors.primaryText;
    if (tx.type == 'INBOUND') typeColor = AppColors.stockIn;
    if (tx.type == 'OUTBOUND') typeColor = AppColors.stockOut;
    if (tx.type == 'ADJUSTMENT') typeColor = const Color(0xFFFF9900);

    Color statusColor = AppColors.stockIn;
    if (tx.status == 'PENDING') statusColor = const Color(0xFFFF9900);
    if (tx.status == 'CANCELLED') statusColor = AppColors.stockOut;

    final dateFormatted =
        DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt ?? DateTime.now());
    final String avatarUrl = 'https://i.pravatar.cc/150?u=$authUserId';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: USER INFO ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.softGrey.withOpacity(0.2),
                        child: const Center(
                            child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary))),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child:
                            const Icon(Icons.person, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText)),
                      Text(displayRole,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subText.withOpacity(0.8))),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(tx.status,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5)),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppColors.softGrey.withOpacity(0.15), thickness: 1),
          const SizedBox(height: 16),

          // --- DETAILS ---
          _buildInfoRow('Transaction ID', tx.transactionId ?? 'N/A',
              isBold: true),
          const SizedBox(height: 12),
          _buildInfoRow('Type', tx.type, valueColor: typeColor, isBold: true),
          const SizedBox(height: 12),
          _buildInfoRow('Date', dateFormatted),
          const SizedBox(height: 12),
          _buildInfoRow('Store', storeName),
          if (tx.note != null && tx.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Note', tx.note!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color valueColor = AppColors.primaryText, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 100,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.subText))),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    color: valueColor,
                    fontFamily: 'Poppins'),
                textAlign: TextAlign.right)),
      ],
    );
  }
}
