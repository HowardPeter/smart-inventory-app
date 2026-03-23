import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/dimension.dart';
import 'package:frontend/core/ui/layouts/t_size_error_layout.dart';

class TResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  // Thêm biến này để cho phép Splash hiển thị trên mọi kích thước
  final bool isAlwaysAllowed;

  const TResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.isAlwaysAllowed = false, // Mặc định vẫn chặn để bảo vệ các trang khác
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    // 1. Nếu là WEB hoặc là trang được ưu tiên (như Splash)
    if (kIsWeb || isAlwaysAllowed) {
      final Widget desktopWidget =
          desktop ?? _buildDefaultPlaceholder("Desktop");
      final Widget tabletWidget = tablet ?? desktopWidget;

      if (width >= TDimension.desktopWidth) return desktopWidget;
      if (width >= TDimension.mobileWidth) return tabletWidget;
      return mobile;
    }
    // 2. Nếu là APP và KHÔNG được ưu tiên -> Chặn nếu màn hình quá to
    else {
      if (width >= TDimension.mobileWidth) return const TSizeErrorLayout();
      return mobile;
    }
  }

  Widget _buildDefaultPlaceholder(String platform) {
    return Scaffold(body: Center(child: Text("$platform Version Coming Soon")));
  }
}
