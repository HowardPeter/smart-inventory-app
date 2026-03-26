import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TExpandableFabWidget extends StatefulWidget {
  final VoidCallback onManualAdd;
  final VoidCallback onScanAdd;

  const TExpandableFabWidget({
    super.key,
    required this.onManualAdd,
    required this.onScanAdd,
  });

  @override
  State<TExpandableFabWidget> createState() => _TExpandableFabWidgetState();
}

class _TExpandableFabWidgetState extends State<TExpandableFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56, // Giới hạn khung chiều rộng đúng bằng nút chính
      height: 220, // Tăng chiều cao khung chứa để đủ chỗ cho các nút to hơn
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Stack(
            alignment:
                Alignment.bottomCenter, // Đảm bảo mọi nút nằm ở giữa trục dọc
            clipBehavior: Clip.none,
            children: [
              // ================================
              // NÚT CON 1: SCAN (NẰM TRÊN CÙNG)
              // ================================
              Positioned(
                // Đẩy lên cao hơn (140) để tránh đè vào nút dưới khi nút to ra
                bottom: 140 * _expandAnimation.value,
                child: Transform.scale(
                  scale: _expandAnimation.value,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    // Tăng size từ 40x40 (small) lên 48x48
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        heroTag: "fab_scan",
                        shape: const CircleBorder(),
                        backgroundColor: const Color(0xFF1E1E24),
                        elevation: 4,
                        onPressed: () {
                          _toggle();
                          widget.onScanAdd();
                        },
                        child: const Icon(Iconsax.scan_barcode_copy,
                            color: Colors.white,
                            size: 22), // Tăng icon size lên 22
                      ),
                    ),
                  ),
                ),
              ),

              // ================================
              // NÚT CON 2: MANUAL EDIT (NẰM GIỮA)
              // ================================
              Positioned(
                // Đẩy lên (75) để tạo khoảng cách đẹp với nút chính
                bottom: 75 * _expandAnimation.value,
                child: Transform.scale(
                  scale: _expandAnimation.value,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    // Tăng size lên 48x48
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        heroTag: "fab_manual",
                        shape: const CircleBorder(),
                        backgroundColor: const Color(0xFF1E1E24),
                        elevation: 4,
                        onPressed: () {
                          _toggle();
                          widget.onManualAdd();
                        },
                        child: const Icon(Iconsax.edit_2_copy,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ),

              // ================================
              // NÚT CHÍNH: NẰM DƯỚI CÙNG
              // ================================
              Positioned(
                bottom: 0,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: "fab_main",
                    shape: const CircleBorder(),
                    backgroundColor:
                        _isOpen ? const Color(0xFF1E1E24) : Colors.black,
                    elevation: 6,
                    onPressed: _toggle,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.125)
                          .animate(_controller),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
