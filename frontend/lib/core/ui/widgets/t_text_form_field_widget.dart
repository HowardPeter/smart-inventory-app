import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

/// Text Input Form Field
class TTextFormField extends StatelessWidget {
  const TTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.isObscure = false, // Đổi tên từ obscureText thành isObscure
    this.suffixIcon,
    this.controller,
    this.onChanged, // Thêm thuộc tính này
  });

  final String label;
  final String hintText;
  final bool isObscure; // Đổi tên ở đây
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged; // Khai báo kiểu function nhận vào String

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
          obscureText: isObscure, // Sử dụng biến mới
          onChanged: onChanged, // Truyền giá trị vào TextFormField gốc
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
            // Logic hiển thị suffixIcon
            suffixIcon: suffixIcon ?? _buildClearButton(),
          ),
        ),
      ],
    );
  }

  /// Nút Xóa nhanh (Chỉ hiển thị khi không phải ô mật khẩu và có chữ)
  Widget? _buildClearButton() {
    if (controller == null || isObscure) {
      return null; // Không hiện nút X nếu là ô mật khẩu
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        if (value.text.isNotEmpty) {
          return IconButton(
            icon: const Icon(
              Icons.cancel,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              controller!.clear();
              if (onChanged != null) {
                onChanged!("");
              }
            },
            splashColor: Colors.transparent,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
