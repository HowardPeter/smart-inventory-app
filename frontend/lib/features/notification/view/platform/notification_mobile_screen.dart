import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// -- IMPORTS UI KIT CỦA BẠN --
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/core/ui/widgets/t_animation_loader_widget.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';

// -- IMPORTS MODULE NOTIFICATION --
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:frontend/features/notification/widgets/notification_card.dart';

class NotificationMobileScreen extends StatelessWidget {
  const NotificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: AppColors.background, // Hoặc AppColors.surface
      // 1. TÁI SỬ DỤNG TAppBarWidget (Chuẩn Blur Effect & Nút Back)
      appBar: TAppBarWidget(
        title: "Thông báo",
        showBackArrow: true,
        centerTitle: true,
        actions: [
          Obx(
            () => controller.unreadCount.value > 0
                ? IconButton(
                    icon: const Icon(Iconsax.task_square_copy,
                        color: AppColors.primary),
                    onPressed: () => controller.markAllAsRead(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        // 2. TÁI SỬ DỤNG TAnimationLoaderWidget (Lúc mới vào)
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const TAnimationLoaderWidget(text: 'Đang tải thông báo...');
        }

        // 3. TÁI SỬ DỤNG TEmptyStateWidget & TPrimaryButtonWidget
        if (controller.notifications.isEmpty) {
          return TEmptyStateWidget(
            icon: Iconsax.notification_bing_copy,
            title: "Không có thông báo nào",
            subtitle: "Khi có cập nhật mới, thông báo sẽ hiển thị tại đây.",
            actionButton: SizedBox(
              width: 200, // Thu nhỏ chiều ngang của nút cho đẹp
              child: TPrimaryButtonWidget(
                text: "Tải lại",
                icon: Iconsax.refresh,
                onPressed: () => controller.fetchNotifications(),
              ),
            ),
          );
        }

        // 4. TÁI SỬ DỤNG TRefreshIndicatorWidget
        return TRefreshIndicatorWidget(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16, vertical: AppSizes.p16),
            // Tính số lượng item = Data length + 1 (Loader nếu có) + 1 (Spacer ở đáy)
            itemCount: controller.notifications.length +
                (controller.isLoadMore.value ? 1 : 0) +
                1,
            itemBuilder: (context, index) {
              // Render Item thông báo
              if (index < controller.notifications.length) {
                final item = controller.notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.p12),
                  child: Dismissible(
                    key: Key(item.notificationId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p24),
                      decoration: BoxDecoration(
                        color: AppColors.stockOut,
                        borderRadius: BorderRadius.circular(AppSizes.radius16),
                      ),
                      child: const Icon(Iconsax.trash_copy,
                          color: AppColors.white, size: 28),
                    ),
                    onDismissed: (direction) {
                      controller.deleteNotificationWithUndo(item, index);
                    },
                    child: NotificationCard(
                      notification: item,
                      timeAgo: controller.formatTimeAgo(item.createdAt),
                      onTap: () => controller.markAsRead(item.notificationId),
                    ),
                  ),
                );
              }
              // Render Loading quay vòng tròn khi scroll xuống đáy
              else if (controller.isLoadMore.value &&
                  index == controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.p24),
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: AppColors.primary),
                  ),
                );
              }
              // 5. TÁI SỬ DỤNG TBottomNavSpacerWidget (Vị trí cuối cùng)
              else {
                return const TBottomNavSpacerWidget();
              }
            },
          ),
        );
      }),
    );
  }
}
