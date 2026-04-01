import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

/// Text Input Form Field
class TTextFormFieldWidget extends StatelessWidget {
  const TTextFormFieldWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.isObscure = false,
    this.isRequired = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final bool isObscure;
  final bool isRequired;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.subText,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.alertText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          maxLines: isObscure ? 1 : maxLines,
          cursorColor: AppColors.primary,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius8),
              borderSide: const BorderSide(color: AppColors.toastErrorBg),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius8),
              borderSide:
                  const BorderSide(color: AppColors.toastErrorBg, width: 1.5),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.softGrey, size: 20)
                : null,
            suffixIcon: suffixIcon ?? _buildClearButton(),
          ),
        ),
      ],
    );
  }

  /// Nút Xóa nhanh
  Widget? _buildClearButton() {
    if (controller == null || isObscure) {
      return null;
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
