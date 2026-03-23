import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/workspace/controllers/add_members_controller.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';

class AddMembersListWidget extends GetView<AddMembersController> {
  const AddMembersListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Trạng thái Loading (Skeleton)
      if (controller.isLoadingMembers.value) {
        return const Padding(
          padding: EdgeInsets.only(top: AppSizes.p16),
          child: TFormSkeletonWidget(itemCount: 4),
        );
      }

      // 2. Trạng thái Trống (Empty State)
      if (controller.members.isEmpty) {
        return TEmptyStateWidget(
          icon: Iconsax.profile_2user_copy,
          title: TTexts.emptyMemberTitle.tr,
          subtitle: TTexts.emptyMemberSubtitle.tr,
        );
      }

      // 3. Danh sách thật
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildMemberCard(controller.members[index]);
        },
      );
    });
  }

  Widget _buildMemberCard(StoreMemberModel member) {
    final isManager = member.role == 'manager';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: isManager
            ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1)
            : Border.all(color: AppColors.softGrey.withOpacity(0.3)),
        boxShadow: [
          if (isManager)
            BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isManager
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.softGrey.withOpacity(0.2),
            child: Icon(isManager ? Iconsax.copy : Iconsax.user_copy,
                color: isManager ? AppColors.primary : AppColors.subText),
          ),
          const SizedBox(width: 16),
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
                Text(member.email,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.subText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isManager
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isManager ? TTexts.roleManager.tr : TTexts.roleStaff.tr,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isManager ? AppColors.primary : Colors.grey[600]),
            ),
          )
        ],
      ),
    );
  }
}
