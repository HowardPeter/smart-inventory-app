import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/features/workspace/controllers/add_members_controller.dart';

class AddMemberRoleBadgeWidget extends StatefulWidget {
  final StoreMemberModel member;
  final bool isCurrentUserOwner;
  final Color roleColor;
  final Color bgColor;

  const AddMemberRoleBadgeWidget({
    super.key,
    required this.member,
    required this.isCurrentUserOwner,
    required this.roleColor,
    required this.bgColor,
  });

  @override
  State<AddMemberRoleBadgeWidget> createState() =>
      _AddMemberRoleBadgeWidgetState();
}

class _AddMemberRoleBadgeWidgetState extends State<AddMemberRoleBadgeWidget>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Animation cho mượt mà
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeMenu() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Lớp nền bắt sự kiện click ra ngoài để đóng menu
          GestureDetector(
            onTap: _closeMenu,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),

          // Menu xổ xuống gắn liền với target
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            followerAnchor: Alignment.topRight,
            targetAnchor: Alignment.bottomRight,
            offset: const Offset(0, 8),
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  alignment: Alignment.topRight,
                  child: IntrinsicWidth(
                    child: _buildGlassmorphismMenu(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismMenu() {
    final controller = Get.find<AddMembersController>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radius16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // Kính mờ
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.85), // Hơi trong suốt
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            border:
                Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option Manager
              _buildMenuItem(
                icon: Iconsax.security_user_copy,
                text: TTexts.roleManager.tr,
                color: AppColors.primary,
                isSelected: widget.member.role == 'manager',
                onTap: () {
                  _closeMenu();
                  if (widget.member.role != 'manager') {
                    controller.changeMemberRole(
                        widget.member.userId, 'manager');
                  }
                },
              ),
              const SizedBox(height: 4),
              // Option Staff
              _buildMenuItem(
                icon: Iconsax.user_copy,
                text: TTexts.roleStaff.tr,
                color: Colors.grey[700],
                isSelected: widget.member.role == 'staff',
                onTap: () {
                  _closeMenu();
                  if (widget.member.role != 'staff') {
                    controller.changeMemberRole(widget.member.userId, 'staff');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color?.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 16),
              Icon(Icons.check_circle, color: color, size: 18),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String roleText = widget.member.role == 'owner'
        ? TTexts.roleOwner.tr
        : (widget.member.role == 'manager'
            ? TTexts.roleManager.tr
            : TTexts.roleStaff.tr);

    // Nút Badge hiển thị thông thường
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            roleText,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.roleColor),
          ),
          // Chỉ thêm icon mũi tên nếu user CÓ QUYỀN thao tác
          if (widget.isCurrentUserOwner &&
              !widget.member.isCurrentUser &&
              widget.member.role != 'owner') ...[
            const SizedBox(width: 4),
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: widget.roleColor,
            ),
          ],
        ],
      ),
    );

    // Bẫy lỗi: KHÔNG CHO PHÉP thao tác nếu:
    // 1. Người đang dùng app không phải Owner.
    // 2. Member này là chính mình (Tự giáng chức).
    // 3. Member này cũng là một Owner khác.
    if (!widget.isCurrentUserOwner ||
        widget.member.isCurrentUser ||
        widget.member.role == 'owner') {
      return badge; // Trả về text tĩnh bình thường
    }

    // Nếu ĐỦ QUYỀN -> Trả về Widget có thể bấm vào và chứa LayerLink
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: badge,
      ),
    );
  }
}
