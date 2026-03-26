import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/routes/app_routes.dart'; // Tuỳ chỉnh lại đường dẫn AppRoutes nếu cần

class TAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // Trữ Text tiêu đề
  final Widget?
      titleWidget; // Cho phép truyền cả Widget vào Title (vd: Hình ảnh, Dropdown)
  final bool showBackArrow; // Bật/Tắt nút Go Back mặc định
  final Widget?
      leadingWidget; // Cho phép thay thế hoàn toàn nút Go Back bằng nút khác
  final List<Widget>?
      actions; // Cho phép truyền vào 1 nùi nút bấm bên phải (vd: Filter, Menu, User Avatar)
  final bool showSearchIcon; // Bật/Tắt nhanh nút Search tích hợp sẵn
  final VoidCallback? onSearchPressed; // Ghi đè sự kiện khi bấm nút Search
  final PreferredSizeWidget? bottom; // Hỗ trợ thêm TabBar ở dưới AppBar

  const TAppBarWidget({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackArrow = true,
    this.leadingWidget,
    this.actions,
    this.showSearchIcon = false,
    this.onSearchPressed,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor:
              AppColors.background.withOpacity(0.7), // Trong suốt 70%
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          // Nếu dùng nút Back dạng Text "Go Back" thì cần độ rộng 120, nếu không thì để mặc định
          leadingWidth: showBackArrow && leadingWidget == null ? 120 : 56,

          // ĐƯỜNG KẺ CHỈ Ở DƯỚI (Hoặc TabBar tuỳ biến)
          bottom: bottom ??
              PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child:
                    Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
              ),

          // NÚT BÊN TRÁI (LEADING)
          leading: leadingWidget ??
              (showBackArrow
                  ? InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(AppSizes.radius8),
                      child: const Row(
                        children: [
                          SizedBox(width: AppSizes.p16),
                          Icon(Iconsax.arrow_left_2_copy,
                              color: AppColors.primaryText, size: 20),
                          SizedBox(width: 4),
                        ],
                      ),
                    )
                  : null),

          // TIÊU ĐỀ (TITLE)
          title: titleWidget ??
              (title != null
                  ? Text(title!,
                      style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'))
                  : null),

          // CÁC NÚT BÊN PHẢI (ACTIONS)
          actions: [
            // 1. Nút Search mặc định (Nếu bật)
            if (showSearchIcon)
              IconButton(
                icon: const Icon(Iconsax.search_normal_copy,
                    color: AppColors.primaryText),
                onPressed: onSearchPressed ??
                    () => Get.toNamed(AppRoutes.search,
                        arguments: {'target': SearchTarget.inventory}),
              ),

            // 2. Chèn thêm các nút Custom mà bạn truyền vào
            ...?actions,

            const SizedBox(width: AppSizes.p8),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
