import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/profile/views/platform/profile_edit_store_mobile_view.dart';

/// View chính đóng vai trò điều phối Responsive cho module Home
class ProfileEditStoreView extends StatelessWidget {
  const ProfileEditStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: EditStoreMobileView()),
    );
  }
}
