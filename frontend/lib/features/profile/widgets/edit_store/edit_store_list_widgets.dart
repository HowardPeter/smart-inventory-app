import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/widgets/edit_store/edit_store_item_widgets.dart';

class EditStoreListWidgets extends StatelessWidget {
  const EditStoreListWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ALL STORES",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          StoreItemWidget(
            name: "Branch 1 - District 1",
            address: "45 Le Loi, HCM",
            members: "5 members",
          ),
          StoreItemWidget(
            name: "Branch 2 - Binh Thanh",
            address: "210 Dien Bien Phu",
            members: "8 members",
          ),
          StoreItemWidget(
            name: "Da Nang Branch",
            address: "78 Bach Dang",
            members: "4 members",
          ),
        ],
      ),
    );
  }
}
