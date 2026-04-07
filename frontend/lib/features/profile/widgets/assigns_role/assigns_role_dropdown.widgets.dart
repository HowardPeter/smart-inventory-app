import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class AssignsRoleDropdownWidget extends StatelessWidget {
  final String role;
  final Function(String) onRoleChanged;

  const AssignsRoleDropdownWidget({
    super.key,
    required this.role,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOwner = role.toLowerCase() == 'owner';

    return PopupMenuButton<String>(
      onSelected: onRoleChanged,
      offset: const Offset(0, 45),
      // Bo góc cho khung Menu trắng ngoài cùng
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius16),
      ),
      elevation: 4,
      // Bỏ padding mặc định của PopupMenu để item có thể tràn viền màu xám
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        _buildMenuItem("Owner", Icons.workspace_premium_outlined,
            AppColors.primary, role == "Owner"),
        _buildMenuItem("Manager", Icons.star_border_rounded, AppColors.primary,
            role == "Manager"),
        _buildMenuItem("Staff", Icons.person_outline_rounded, AppColors.subText,
            role == "Staff"),
      ],
      child: _buildBadge(isOwner),
    );
  }

  // Hàm tạo Item trong Menu với hiệu ứng
  PopupMenuItem<String> _buildMenuItem(
      String value, IconData icon, Color iconColor, bool isSelected) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          // tô nền xám và bo góc
          color: isSelected
              ? AppColors.softGrey.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
        ),
        child: Row(
          children: [
            // Icon có vòng tròn nhẹ phía sau
            Icon(icon,
                size: 20, color: isSelected ? AppColors.primary : iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            // Hiển thị icon tick hoặc mũi tên xuống nếu là item đang chọn
            if (isSelected)
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: AppColors.subText),
          ],
        ),
      ),
    );
  }

  // Nút bấm hiển thị bên ngoài (Badge)
  Widget _buildBadge(bool isOwner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOwner
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.softGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radius24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            role,
            style: TextStyle(
              color: isOwner ? AppColors.primary : AppColors.primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isOwner ? Icons.chevron_right : Icons.keyboard_arrow_down,
            size: 16,
            color: isOwner ? AppColors.primary : AppColors.subText,
          ),
        ],
      ),
    );
  }
}
