import 'package:flutter/material.dart';
import 'package:frontend/features/workspace/widgets/join_store/join_store_header_widget.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/workspace/controllers/join_store_controller.dart';
import '../../widgets/join_store/join_store_input_field_widget.dart'; // Import Widget mới

class JoinStoreMobileView extends GetView<JoinStoreController> {
  const JoinStoreMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Header Component chung cho 2 trang
      appBar: const TBlurAppBarWidget(),

      // BODY: Chỉ chứa nội dung Form, không chứa nút bấm
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.p16),

              // 1. TIÊU ĐỀ (GỌI WIDGET ĐÃ TÁCH)
              const JoinStoreHeaderWidget(),

              const SizedBox(height: AppSizes.p48),

              // 2. Ô NHẬP MÃ (GỌI WIDGET ĐÃ TÁCH)
              const JoinStoreInputFieldWidget(),

              // Thêm khoảng trống và chữ "or" như hình
              // const SizedBox(height: AppSizes.p32),
              // Center(
              //   child: Text(
              //     TTexts.authOrDivider.tr, // Thêm "or" vào TTexts
              //     style: TextStyle(color: Colors.grey[400]),
              //   ),
              // ),
              // const SizedBox(height: AppSizes.p32),

              // // Bạn có thể thêm các option khác ở đây, ví dụ scan QR
              // Center(
              //   child: TextButton.icon(
              //     onPressed: () {},
              //     icon: const Icon(Icons.qr_code_scanner,
              //         color: AppColors.primary),
              //     label: const Text("Scan QR Code",
              //         style: TextStyle(
              //             color: AppColors.primary,
              //             fontWeight: FontWeight.bold)),
              //   ),
              // ),

              // Tạo khoảng trống dưới cùng phòng khi vuốt
              const SizedBox(height: AppSizes.p48),

              Obx(() => TPrimaryButtonWidget(
                    text: controller.isLoading.value
                        ? TTexts.joiningBtn.tr
                        : TTexts.joinBtn.tr,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.onJoinWorkspace,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
