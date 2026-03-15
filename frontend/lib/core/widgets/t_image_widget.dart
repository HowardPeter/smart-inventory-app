import 'package:flutter/material.dart';

/// Widget hiển thị hình ảnh dùng chung cho toàn bộ ứng dụng.
/// Hỗ trợ tùy chỉnh kích thước, cách hiển thị và bo góc.
class TImageWidget extends StatelessWidget {
  // 1. Final variables
  final String image;
  final double? width, height;
  final BoxFit fit;
  final double borderRadius;
  final Color? overlayColor;

  // 2. Constructor
  const TImageWidget({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 0,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        image,
        width: width,
        height: height,
        fit: fit,
        color: overlayColor,
      ),
    );
  }
}
