import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class AssignsRoleMembersView extends StatelessWidget {
  const AssignsRoleMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockMembers = [
      {
        "name": "Hagia Linh",
        "role": "Owner",
        "image": "https://i.pravatar.cc/150?u=1"
      },
      {
        "name": "An Nguyễn",
        "role": "Manager",
        "image": "https://i.pravatar.cc/150?u=2"
      },
      {
        "name": "Bình Trần",
        "role": "Staff",
        "image": "https://i.pravatar.cc/150?u=3"
      },
      {
        "name": "Nam Lê",
        "role": "Staff",
        "image": "https://i.pravatar.cc/150?u=4"
      },
      {
        "name": "Đức Phạm",
        "role": "Staff",
        "image": "https://i.pravatar.cc/150?u=5"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TIÊU ĐỀ MEMBERS ---
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16, vertical: AppSizes.p12),
          child: Text(
            "Members (${mockMembers.length})",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText),
          ),
        ),

        // --- DANH SÁCH CHI TIẾT ---
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
          itemCount: mockMembers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final member = mockMembers[index];
            final String role = member['role']!;

            // Logic xác định Icon và màu sắc dựa trên role
            IconData roleIcon;
            Color roleColor;
            switch (role.toLowerCase()) {
              case 'owner':
                roleIcon = Icons.workspace_premium; // Icon vương miện/huy hiệu
                roleColor = AppColors.primary; // Cam
                break;
              case 'manager':
                roleIcon = Icons.stars; // Icon ngôi sao
                roleColor = AppColors.primary; // Cam
                break;
              default:
                roleIcon = Icons.person_outline; // Icon user
                roleColor = AppColors.subText; // Xám
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius16),
                // Border mờ hơn để tạo cảm giác "Clean"
                border: Border.all(color: AppColors.softGrey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Avatar với Border nhẹ bao quanh
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: roleColor.withOpacity(0.2)),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(member['image']!),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Thông tin chi tiết
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name']!,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(roleIcon, size: 14, color: roleColor),
                            const SizedBox(width: 4),
                            Text(
                              role,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: roleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
