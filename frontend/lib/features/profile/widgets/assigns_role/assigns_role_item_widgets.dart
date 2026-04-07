import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'assigns_role_dropdown.widgets.dart';

class AssignsRoleItemWidget extends StatelessWidget {
  final String name;
  final String role;
  final String image;
  final Function(String) onRoleChanged;

  const AssignsRoleItemWidget({
    super.key,
    required this.name,
    required this.role,
    required this.image,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.softGrey.withOpacity(0.1),
            backgroundImage: NetworkImage(image),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  role,
                  style:
                      const TextStyle(color: AppColors.subText, fontSize: 13),
                ),
              ],
            ),
          ),
          // Gọi Dropdown custom đã làm ở trên
          AssignsRoleDropdownWidget(
            role: role,
            onRoleChanged: onRoleChanged,
          ),
        ],
      ),
    );
  }
}
