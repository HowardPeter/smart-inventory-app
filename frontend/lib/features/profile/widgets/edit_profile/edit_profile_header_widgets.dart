import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class EditProfileHeaderWidget extends StatelessWidget {
  const EditProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientOrangeStart,
                  AppColors.gradientOrangeEnd,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.p48),
                bottomRight: Radius.circular(AppSizes.p48),
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSizes.p8),
                child: SizedBox(
                  height: AppSizes.p48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: AppSizes.p8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.whiteText,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Text(
                        TTexts.editTitle.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.whiteText,
                          fontSize: AppSizes.p22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// AVATAR
          Positioned(
            top: 125,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientBlackStart.withOpacity(0.08),
                    blurRadius: AppSizes.radius15,
                    offset: const Offset(0, AppSizes.p8),
                  )
                ],
              ),
              child: CircleAvatar(
                radius: AppSizes.radius55,
                backgroundImage: AssetImage(
                  TImages.profileImages.profileImageUser,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
