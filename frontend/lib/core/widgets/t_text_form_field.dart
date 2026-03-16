import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

/// Text Input Form Field
class TTextFormField extends StatelessWidget {
  const TTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
  });

  final String label;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon; // Để chứa icon con mắt mở/nhắm
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subText,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.softGrey,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            // XỬ LÝ HIỂN THỊ NÚT X
            // Nếu có truyền suffixIcon (như con mắt) thì dùng.
            // Nếu không, tự động kiểm tra và build nút X
            suffixIcon: suffixIcon ?? _buildClearButton(),
          ),
        ),
      ],
    );
  }

  /// Nút Xóa nhanh (Chỉ hiển thị khi có controller và đang có chữ)
  Widget? _buildClearButton() {
    // Nếu không truyền controller thì không thể xóa chữ được -> ẩn nút
    if (controller == null) return null;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        // Hễ có chữ là hiện ra nút IconButton X
        if (value.text.isNotEmpty) {
          return IconButton(
            icon: const Icon(
              Icons.cancel,
              color: Colors.grey,
              size: 20,
            ), // Dùng icon cancel bo tròn cho đẹp
            onPressed: () {
              controller!.clear(); // Bấm vào là xóa trắng ô nhập
            },
            splashColor: Colors.transparent, // Tắt hiệu ứng loang lổ khi bấm
          );
        }
        return const SizedBox.shrink(); // Ẩn đi khi không có chữ
      },
    );
  }
}
