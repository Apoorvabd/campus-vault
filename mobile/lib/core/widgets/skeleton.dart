import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

const _base = Color(0xFFE8EDF3);
const _highlight = Color(0xFFF7F9FC);

/// Makes every [SkeletonBox] inside it shimmer in sync (one animation for the
/// whole placeholder, however many boxes it holds).
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _controller.value * 3 - 1; // -1 .. 2 across the width
            return LinearGradient(
              begin: Alignment(slide - 1, 0),
              end: Alignment(slide, 0),
              colors: const [_base, _highlight, _base],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        ),
      ),
    );
  }
}

/// One grey placeholder block (a text line, an avatar, a button...).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: circle ? height : width,
    height: height,
    decoration: BoxDecoration(
      color: _base,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(radius),
    ),
  );
}

Widget _gap(double h) => SizedBox(height: h);

/// Placeholder for the "Your Subjects" rows.
class SkeletonSubjectList extends StatelessWidget {
  const SkeletonSubjectList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          const AppCard(
            child: Row(
              children: [
                SkeletonBox(height: 44, radius: AppRadius.iconBox, width: 44),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 150, height: 14),
                      SizedBox(height: 8),
                      SkeletonBox(width: 90, height: 10),
                    ],
                  ),
                ),
                SkeletonBox(height: 32, circle: true),
              ],
            ),
          ),
          if (i < count - 1) _gap(AppSpacing.md),
        ],
      ],
    ),
  );
}

/// Placeholder for resource cards (notes, PYQs, ...).
class SkeletonResourceList extends StatelessWidget {
  const SkeletonResourceList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    SkeletonBox(
                      width: 44,
                      height: 44,
                      radius: AppRadius.iconBox,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(height: 14),
                          SizedBox(height: 8),
                          SkeletonBox(width: 120, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                _gap(AppSpacing.md),
                const Row(
                  children: [
                    SkeletonBox(width: 70, height: 24, radius: AppRadius.pill),
                    Spacer(),
                    SkeletonBox(width: 90, height: 32, radius: AppRadius.pill),
                  ],
                ),
              ],
            ),
          ),
          if (i < count - 1) _gap(AppSpacing.md),
        ],
      ],
    ),
  );
}

/// Placeholder for community post cards.
class SkeletonPostList extends StatelessWidget {
  const SkeletonPostList({super.key, this.count = 2});

  final int count;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(height: 40, circle: true),
                    SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120, height: 12),
                        SizedBox(height: 6),
                        SkeletonBox(width: 80, height: 10),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(height: 12),
                SizedBox(height: 8),
                SkeletonBox(height: 12),
                SizedBox(height: 8),
                SkeletonBox(width: 180, height: 12),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    SkeletonBox(width: 50, height: 20),
                    SizedBox(width: AppSpacing.lg),
                    SkeletonBox(width: 50, height: 20),
                  ],
                ),
              ],
            ),
          ),
          if (i < count - 1) _gap(AppSpacing.md),
        ],
      ],
    ),
  );
}

/// Placeholder for the profile header card (avatar, name, course lines).
class SkeletonProfileCard extends StatelessWidget {
  const SkeletonProfileCard({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: AppCard(
      child: Row(
        children: [
          SkeletonBox(height: 56, circle: true),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 16),
                SizedBox(height: 10),
                SkeletonBox(width: 190, height: 11),
                SizedBox(height: 8),
                SkeletonBox(width: 120, height: 11),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Placeholder for comment rows.
class SkeletonCommentList extends StatelessWidget {
  const SkeletonCommentList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: count,
      separatorBuilder: (_, _) => _gap(AppSpacing.lg),
      itemBuilder: (_, _) => const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 34, circle: true),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 100, height: 11),
                SizedBox(height: 8),
                SkeletonBox(height: 11),
                SizedBox(height: 6),
                SkeletonBox(width: 160, height: 11),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Placeholder for a form made of labelled dropdowns / text fields.
class SkeletonForm extends StatelessWidget {
  const SkeletonForm({super.key, this.fields = 6});

  final int fields;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SkeletonBox(width: 110, height: 12),
        _gap(AppSpacing.lg),
        for (var i = 0; i < fields; i++) ...[
          const SkeletonBox(width: 80, height: 13),
          _gap(AppSpacing.sm),
          const SkeletonBox(height: 48, radius: AppRadius.input),
          _gap(AppSpacing.lg),
        ],
      ],
    ),
  );
}
