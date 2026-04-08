import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';

class EditStoreCardWidgets extends StatelessWidget {
  const EditStoreCardWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.editStoreCurrentStore.tr,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFFFE0C2),
                  child: Icon(Iconsax.shop_copy, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị tên cửa hàng thực tế và tự động cập nhật
                      Obx(() => Text(
                            controller.storeName.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )),
                      const SizedBox(height: 4),
                      const Text(
                        "23 Nguyen Hue, HCM1", // todo: Thay bằng địa chỉ thật của cửa hàng khi có API lấy chi tiết store
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      // GIỮ LẠI SỐ MEMBER TẠI ĐÂY
                      const Text(
                        "12 members", //todo: Thay bằng số member thật của cửa hàng khi có API lấy chi tiết store
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Nút Edit
                GestureDetector(
                  onTap: () => controller.goToEditStoreProfile(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0C2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      TTexts.editStoreBtnEdit.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
