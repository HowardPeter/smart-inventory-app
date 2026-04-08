import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';

class TransactionHeaderWidget extends StatelessWidget {
  final String? imageUrl;

  const TransactionHeaderWidget({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: AppColors.background.withOpacity(0.7),
      elevation: 0,
      leadingWidth: 64,
      leading: InkWell(
        onTap: () => Get.back(),
        borderRadius: BorderRadius.circular(AppSizes.radius8),
        child: const Center(
          child: Icon(
            Iconsax.arrow_left_2_copy,
            color: AppColors.primaryText,
            size: 24,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: (imageUrl != null && imageUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const TNoImageWidget(
                  iconSize: 64,
                  borderRadius: 0,
                ),
              )
            : const TNoImageWidget(
                iconSize: 64,
                borderRadius: 0,
              ),
      ),
    );
  }
}
