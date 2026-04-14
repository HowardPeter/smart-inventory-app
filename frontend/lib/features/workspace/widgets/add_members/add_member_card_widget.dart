import 'package:flutter/material.dart';
import 'package:frontend/features/workspace/widgets/add_members/add_member_role_badge_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';

class AddMemberCardWidget extends StatelessWidget {
  final StoreMemberModel member;
  final bool isCurrentUserOwner;

  const AddMemberCardWidget({
    super.key,
    required this.member,
    required this.isCurrentUserOwner,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = member.role == 'owner';
    final isManager = member.role == 'manager';

    Color roleColor = isOwner
        ? Colors.orange
        : (isManager ? AppColors.primary : AppColors.stockIn);

    Color bgColor = isOwner
        ? Colors.orange.withOpacity(0.1)
        : (isManager
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.stockIn.withOpacity(0.1));
    bool hasHighlight = isOwner || isManager;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: hasHighlight
                ? roleColor.withOpacity(0.5)
                : AppColors.stockIn.withOpacity(0.3),
            width: 1),
        boxShadow: [
          if (hasHighlight)
            BoxShadow(
                color: roleColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // 1. AVATAR
          CircleAvatar(
            backgroundColor: bgColor,
            child: Icon(
                isOwner
                    ? Iconsax.crown_1_copy
                    : (isManager
                        ? Iconsax.security_user_copy
                        : Iconsax.user_copy),
                color: roleColor),
          ),
          const SizedBox(width: 16),

          // 2. THÔNG TIN (Tên & Email)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (member.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.secondPrimary,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(TTexts.youBadge.tr,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                // ÉP EMAIL DÀI THÀNH ...
                Text(
                  member.email,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.subText),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 3. ROLE BADGE / COMBO BOX
          AddMemberRoleBadgeWidget(
            member: member,
            isCurrentUserOwner: isCurrentUserOwner,
            roleColor: roleColor,
            bgColor: bgColor,
          ),
        ],
      ),
    );
  }
}
