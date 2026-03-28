import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

// ĐÃ IMPORT WIDGET OVERLAY CỦA BẠN
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';

class InventoryDynamicCategoryWidget extends StatelessWidget {
  const InventoryDynamicCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    final List<Color> avatarColors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo
    ];

    return Obx(() {
      final dynamicCategories = controller.categoryStats;

      const int maxDisplay = 6;
      final bool hasMore = dynamicCategories.length > maxDisplay;
      final int itemCount = hasMore ? maxDisplay : dynamicCategories.length;

      if (dynamicCategories.isEmpty) {
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(TTexts.noCategoriesFound.tr,
              style: const TextStyle(color: AppColors.softGrey)),
        ));
      }

      Widget gridView = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          final cat = dynamicCategories[index];
          final String name = cat.name;
          final int count = cat.count;
          final String firstLetter =
              name.isNotEmpty ? name[0].toUpperCase() : "?";
          final Color bgColor = avatarColors[index % avatarColors.length];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softGrey.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(firstLetter,
                      style: TextStyle(
                          color: bgColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text("$count ${TTexts.items.tr}",
                          style: const TextStyle(
                              color: AppColors.softGrey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (hasMore) {
        final int hiddenCount = dynamicCategories.length - maxDisplay;
        return Stack(
          children: [
            gridView,
            TCustomFadeOverlayWidget(
              text: "+$hiddenCount ${TTexts.more.tr}",
              onTap: () => Get.toNamed(AppRoutes.productCatalog),
            ),
          ],
        );
      }

      return gridView;
    });
  }
}
