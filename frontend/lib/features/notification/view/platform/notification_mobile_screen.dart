import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/features/notification/widgets/notification_card.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotificationMobileScreen extends StatelessWidget {
  const NotificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text("Thông báo",
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Obx(
            () => notificationController.unreadCount.value > 0
                ? IconButton(
                    icon: const Icon(Iconsax.task_square_copy,
                        color: AppColors.primary),
                    onPressed: () => notificationController.markAllAsRead(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (notificationController.isLoading.value &&
            notificationController.notifications.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (notificationController.notifications.isEmpty) {
          return TEmptyStateWidget(
            icon: Iconsax.notification_bing_copy,
            title: "Không có thông báo nào",
            subtitle: "Khi có cập nhật mới, thông báo sẽ hiển thị tại đây.",
            actionButton: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton.icon(
                onPressed: () => notificationController.fetchNotifications(),
                icon: const Icon(Icons.refresh),
                label: const Text("Tải lại"),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: notificationController.fetchNotifications,
          child: ListView.builder(
            controller: notificationController.scrollController,
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: notificationController.notifications.length +
                (notificationController.isLoadMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < notificationController.notifications.length) {
                final item = notificationController.notifications[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  // BỌC DISMISSIBLE ĐỂ VUỐT XOÁ
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
                      notificationController
                          .deleteNotification(item.notificationId);
                    },
                    child: NotificationCard(
                      notification: item,
                      timeAgo: notificationController
                          .formatTimeAgo(item.createdAt), // Dùng thời gian thật
                      onTap: () => notificationController
                          .markAsRead(item.notificationId),
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary)),
                );
              }
            },
          ),
        );
      }),
    );
  }
}
