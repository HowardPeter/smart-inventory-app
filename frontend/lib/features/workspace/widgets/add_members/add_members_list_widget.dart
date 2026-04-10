import 'package:flutter/material.dart';
import 'package:frontend/features/workspace/widgets/add_members/add_member_card_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/workspace/controllers/add_members_controller.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';

class AddMembersListWidget extends GetView<AddMembersController> {
  const AddMembersListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMembers.value) {
        return const Padding(
          padding: EdgeInsets.only(top: AppSizes.p16),
          child: TFormSkeletonWidget(itemCount: 4),
        );
      }

      if (controller.members.isEmpty) {
        return TEmptyStateWidget(
          icon: Iconsax.profile_2user_copy,
          title: TTexts.emptyMemberTitle.tr,
          subtitle: TTexts.emptyMemberSubtitle.tr,
        );
      }

      final bool isCurrentUserOwner =
          controller.members.any((m) => m.isCurrentUser && m.role == 'owner');

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return AddMemberCardWidget(
            member: controller.members[index],
            isCurrentUserOwner: isCurrentUserOwner,
          );
        },
      );
    });
  }
}
