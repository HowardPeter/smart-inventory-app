import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:frontend/features/transaction/widgets/transaction_summary/transaction_summary_details_bottom_sheet_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart'; // IMPORT WIDGET CHUNG
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionSummaryController extends GetxController {
  late final TransactionModel transaction;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is TransactionModel) {
      transaction = Get.arguments;
    } else {
      Get.back();
    }
  }

  bool get isInbound => transaction.type == 'INBOUND';
  bool get isOutbound => transaction.type == 'OUTBOUND';
  bool get isAdjustment => transaction.type == 'ADJUSTMENT';

  int get totalItems =>
      transaction.items.fold<int>(0, (int sum, item) => sum + (item.quantity));

  String get itemsDisplay => isInbound
      ? '+$totalItems'
      : (isOutbound ? '-$totalItems' : '$totalItems');
  Color get itemsColor => isInbound
      ? AppColors.stockIn
      : (isOutbound ? AppColors.stockOut : Colors.orange);

  double get rawTotal => transaction.totalPrice;

  Color get moneyColor {
    if (rawTotal > 0) {
      return isInbound ? AppColors.stockOut : AppColors.stockIn;
    } else if (rawTotal < 0) {
      return AppColors.stockOut;
    }
    return AppColors.subText;
  }

  String get moneyDisplay {
    if (rawTotal > 0) {
      return isInbound
          ? '-\$${rawTotal.toStringAsFixed(2)}'
          : '+\$${rawTotal.toStringAsFixed(2)}';
    } else if (rawTotal < 0) {
      return '-\$${rawTotal.abs().toStringAsFixed(2)}';
    }
    return '\$0.00';
  }

  String get typeDisplay {
    if (isInbound) return TTexts.inbound.tr;
    if (isOutbound) return TTexts.outbound.tr;
    if (isAdjustment) return TTexts.stockAdjustment.tr;
    return transaction.type;
  }

  Color get typeColor {
    if (isInbound) return AppColors.stockIn;
    if (isOutbound) return AppColors.stockOut;
    if (isAdjustment) return Colors.orange;
    return AppColors.primaryText;
  }

  String get dateStr =>
      DateFormat('d MMMM yyyy').format(transaction.createdAt ?? DateTime.now());

  void goToHome() {
    Get.until((route) => route.isFirst);
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeIndex(0);
    }
  }

  void openDetailsBottomSheet() {
    TBottomSheetWidget.show(
      title: TTexts.transactionDetails.tr,
      child: const TransactionSummaryDetailsBottomSheetWidget(),
    );
  }
}
