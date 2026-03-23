import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/workspace/views/platform/workspace_ready_mobile_view.dart';

class WorkspaceReadyView extends StatelessWidget {
  const WorkspaceReadyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: WorkspaceReadyMobileView()),
    );
  }
}
