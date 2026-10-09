import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Underline tabs (2+ options), e.g. "Community" / "Resources" on Home: equal
/// width segments, the selected one in the accent color with a bar under it,
/// and a hairline under the whole row. Icons are optional.
///
/// Pass a [controller] (shared with a `TabBarView`) and the bar follows the
/// finger while the pages are dragged, and tapping a tab slides the pages.
/// Without a controller it works from [selectedIndex] / [onChanged].
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    this.controller,
    this.selectedIndex = 0,
    this.onChanged,
    this.icons,
    this.fontSize = 17,
    this.height = 44,
  }) : assert(labels.length >= 2),
       assert(icons == null || icons.length == labels.length),
       assert(controller != null || onChanged != null);

  final List<String> labels;
  final TabController? controller;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final List<IconData>? icons;
  final double fontSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    final animation = controller?.animation;
    if (animation == null) return _build(selectedIndex.toDouble(), false);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => _build(animation.value, true),
    );
  }

  void _select(int index) {
    if (controller != null) {
      controller!.animateTo(index);
    } else {
      onChanged!(index);
    }
  }

  Widget _build(double position, bool followsFinger) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;
          final bar = ColoredBox(color: AppColors.primary);
          return Stack(
            children: [
              // hairline under the whole row
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
              ),
              if (followsFinger)
                Positioned(
                  left: segmentWidth * position,
                  bottom: 0,
                  width: segmentWidth,
                  height: 3,
                  child: bar,
                )
              else
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  left: segmentWidth * position,
                  bottom: 0,
                  width: segmentWidth,
                  height: 3,
                  child: bar,
                ),
              Row(
                children: List.generate(labels.length, (index) {
                  // 1 when this tab is fully selected, 0 when fully away
                  final t = (1 - (position - index).abs()).clamp(0.0, 1.0);
                  final color = Color.lerp(
                    AppColors.textSecondary,
                    AppColors.primary,
                    t,
                  )!;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(index),
                      // Label sits close to the bar underneath it
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icons != null) ...[
                                Icon(
                                  icons![index],
                                  size: fontSize + 5,
                                  color: color,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  labels[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySemiBold.copyWith(
                                    fontSize: fontSize,
                                    fontWeight: t > 0.5
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
