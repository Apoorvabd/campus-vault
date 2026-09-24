import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A self-contained looping "float" animation for a single icon —
/// used where Lottie was previously wired on the landing screen.
class FloatingIcon extends StatefulWidget {
  const FloatingIcon({super.key, required this.icon, this.size = 96});

  final IconData icon;
  final double size;

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offsetY = -12 * _controller.value;
        return Transform.translate(offset: Offset(0, offsetY), child: child);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(widget.icon, color: AppColors.primary, size: widget.size * 0.5),
      ),
    );
  }
}