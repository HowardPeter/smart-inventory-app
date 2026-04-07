// import 'package:flutter/material.dart';
// import 'package:frontend/core/infrastructure/constants/text_strings.dart';
// import 'package:frontend/core/ui/theme/app_colors.dart';
// import 'package:frontend/core/ui/theme/app_sizes.dart';
// import 'package:get/get.dart';

// class AssignsRoleHeaderWidget extends StatelessWidget {
//   const AssignsRoleHeaderWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(AppSizes.p16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 TTexts.assignsRoleTitle.tr,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryText,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 TTexts.assignsRoleSubtitle.tr,
//                 style: const TextStyle(
//                   color: AppColors.subText,
//                 ),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.gradientOrangeStart,
//               foregroundColor: AppColors.whiteText,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             ),
//             child: Text(TTexts.assignsRoleBtnSave.tr),
//           ),
//         ],
//       ),
//     );
//   }
// }
