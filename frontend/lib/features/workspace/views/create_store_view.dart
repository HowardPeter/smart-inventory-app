import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/workspace/views/platform/create_store_mobile_view.dart';

class CreateStoreView extends StatelessWidget {
  const CreateStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: CreateStoreMobileView()),
    );
  }
}
