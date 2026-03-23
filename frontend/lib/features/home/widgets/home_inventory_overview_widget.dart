import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:frontend/features/home/widgets/home_inventory_header_widget.dart';
import 'package:frontend/features/home/widgets/home_inventory_legend_widget.dart';
import 'package:frontend/features/home/widgets/home_inventory_progress_widget.dart';
import 'package:frontend/features/home/widgets/home_transaction_list_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class HomeInventoryOverviewWidget extends StatelessWidget {
  const HomeInventoryOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
      ),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeInventoryHeaderWidget(),
                SizedBox(height: AppSizes.p20),
                HomeInventoryProgressWidget(),
                SizedBox(height: AppSizes.p16),
                HomeInventoryLegendWidget(),
                SizedBox(height: AppSizes.p24),
                HomeTransactionListWidget(),
                SizedBox(height: 30),
              ],
            ),
          ),

          // SỬ DỤNG WIDGET CHUNG Ở ĐÂY
          TCustomFadeOverlayWidget(
            text: TTexts.homeTapToViewMoreHistory.tr,
            onTap: () {
              // TODO: Xử lý chuyển trang
            },
          ),
        ],
      ),
    );
  }
}
