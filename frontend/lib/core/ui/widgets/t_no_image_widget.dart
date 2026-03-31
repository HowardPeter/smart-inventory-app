import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TNoImageWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double iconSize;
  final double borderRadius;

  const TNoImageWidget({
    super.key,
    this.width,
    this.height,
    this.iconSize = 32.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            AppColors.softGrey.withOpacity(0.08), // Nền xám cực mờ, sang trọng
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.image_copy, // Icon bức ảnh trống
              color: AppColors.softGrey.withOpacity(0.4),
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }
}
