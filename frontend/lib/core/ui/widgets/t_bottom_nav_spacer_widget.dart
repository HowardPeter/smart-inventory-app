import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class TBottomNavSpacerWidget extends StatelessWidget {
  /// Biến này dùng trong trường hợp bạn muốn khoảng trống cao hơn hoặc thấp hơn bình thường một chút
  final double? customHeight;

  const TBottomNavSpacerWidget({
    super.key,
    this.customHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu có dùng SafeArea ở ngoài thì đôi khi kết hợp thêm MediaQuery padding bottom
    // để tránh đè lên thanh Home (vuốt lên) của iOS.
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: (customHeight ?? AppSizes.bottomNavSpacer) + systemBottomPadding,
    );
  }
}
