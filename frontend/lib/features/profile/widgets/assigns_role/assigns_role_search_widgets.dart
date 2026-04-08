import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class AssignsRoleSearchWidget extends StatefulWidget {
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const AssignsRoleSearchWidget({
    super.key,
    required this.hintText,
    this.onTap,
    required this.onChanged,
    this.controller,
  });

  @override
  State<AssignsRoleSearchWidget> createState() =>
      _AssignsRoleSearchWidgetState();
}

class _AssignsRoleSearchWidgetState extends State<AssignsRoleSearchWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        boxShadow: [
          BoxShadow(
            color: AppColors.softGrey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          cursorColor: AppColors.primary,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            // Giữ nguyên hintText, Flutter sẽ tự ẩn nó khi người dùng gõ chữ
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.softGrey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Icon(
                Iconsax.search_normal_copy,
                color: AppColors.softGrey,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            // Nút xóa nhanh
            suffixIcon: _buildClearButton(),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  /// Nút Xóa nhanh (Style giống TTextFormFieldWidget)
  Widget? _buildClearButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        if (value.text.isNotEmpty) {
          return IconButton(
            icon: const Icon(
              Icons.cancel,
              color: Colors.grey,
              size: 18,
            ),
            onPressed: () {
              _controller.clear();
              widget.onChanged("");
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
