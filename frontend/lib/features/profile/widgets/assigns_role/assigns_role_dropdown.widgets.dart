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

    // Nếu là Owner, trả về Badge tĩnh, không có PopupMenuButton
    if (isOwner) {
      return _buildBadge(true);
    }

    return PopupMenuButton<String>(
      onSelected: onRoleChanged,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius16),
      ),
      elevation: 4,
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        // Chỉ cho phép chuyển đổi giữa Manager và Staff
        _buildMenuItem("Manager", Icons.star_border_rounded, AppColors.primary,
            role == "Manager"),
        _buildMenuItem("Staff", Icons.person_outline_rounded, AppColors.subText,
            role == "Staff"),
      ],
      child: _buildBadge(false),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      String value, IconData icon, Color defaultIconColor, bool isSelected) {
    final bool isStaffValue = value.toLowerCase() == 'staff';

    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.softGrey.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: (isStaffValue)
                  ? defaultIconColor
                  : (isSelected ? AppColors.primary : defaultIconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  // Chữ cũng giữ màu xám cho Staff kể cả khi chọn
                  color: (isStaffValue)
                      ? AppColors.primaryText
                      : (isSelected
                          ? AppColors.primary
                          : AppColors.primaryText),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded,
                  size: 18,
                  color: isStaffValue ? AppColors.subText : AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(bool isOwner) {
    final bool isStaff = role.toLowerCase() == 'staff';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isOwner ? 16 : 12,
        vertical: isOwner ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: (isOwner || !isStaff)
            ? AppColors.primary.withOpacity(0.12)
            : AppColors.softGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        border: isOwner
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            role,
            style: TextStyle(
              color: isStaff ? AppColors.primaryText : AppColors.primary,
              fontWeight: isOwner ? FontWeight.w800 : FontWeight.w600,
              fontSize: isOwner ? 15 : 13,
              letterSpacing: isOwner ? 0.4 : 0,
            ),
          ),
          if (!isOwner) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isStaff ? AppColors.subText : AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }
}
