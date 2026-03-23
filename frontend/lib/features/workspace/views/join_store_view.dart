import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/workspace/views/platform/join_store_mobile_view.dart';

class JoinStoreView extends StatelessWidget {
  const JoinStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: JoinStoreMobileView()),
    );
  }
}
