// lib/features/workspace/widgets/join_store/join_store_input_field_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Thêm import này
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/workspace/controllers/join_store_controller.dart';

class JoinStoreInputFieldWidget extends GetView<JoinStoreController> {
  const JoinStoreInputFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NHÃN CHO Ô NHẬP MÃ
        Text(
          TTexts.enterInviteCodeLabel.tr,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: AppSizes.p12),

        // Ô NHẬP MÃ MỜI ĐƯỢC LÀM ĐẸP (CÓ ĐỔ BÓNG NỔI LÊN)
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8), // Đổ bóng nhẹ xuống dưới
              ),
            ],
          ),
          child: TextFormField(
            controller: controller.inviteCodeController,
            textAlign: TextAlign.center,
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
            style: const TextStyle(
                fontSize: 32, // Chữ to hơn một chút
                fontWeight: FontWeight.w900,
                letterSpacing: 10.0, // Khoảng cách xa ra cho giống OTP
                color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: TTexts.enterInviteCodeHint.tr,
              hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: AppColors.softGrey.withOpacity(0.5),
                  letterSpacing: 2.0),
              counterText: "", // Ẩn biến đếm độ dài
              filled: true,
              fillColor: Colors
                  .transparent, // Nền trong suốt để Container bọc ngoài lo
              contentPadding:
                  const EdgeInsets.symmetric(vertical: AppSizes.p24),
              // Xóa viền mặc định để nhường chỗ cho bóng đổ
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius16),
                borderSide: BorderSide.none,
              ),
              // Khi nhấp vào thì hiện viền màu cam xịn xò
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Bổ trợ: Ép chữ hoa khi người dùng nhập từ bàn phím
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
