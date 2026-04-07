// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:frontend/core/ui/theme/app_colors.dart';
// import 'package:frontend/core/ui/theme/app_sizes.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';

// class EditStoreHeaderWidgets extends StatelessWidget {
//   const EditStoreHeaderWidgets({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(AppSizes.p16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Get.back(),
//                 child: const Row(
//                   children: [
//                     Icon(Iconsax.arrow_left_copy, size: 20),
//                     SizedBox(width: 4),
//                     Text("Back"),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Iconsax.add_copy, color: AppColors.primary),
//               )
//             ],
//           ),
//           const SizedBox(height: AppSizes.p16),
//           const Text(
//             "My Stores",
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             "Manage and switch between your stores",
//             style: TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }
