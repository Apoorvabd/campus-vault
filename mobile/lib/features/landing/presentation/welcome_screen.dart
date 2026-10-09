import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/app_logo.dart';

/// Colors of the welcome screen (it has its own purple look, separate from
/// the in-app palette in AppColors).
class WelcomeColors {
  WelcomeColors._();

  static const bg = Color(0xFF4B2BD6);
  static const ink = Color(0xFF140C2E);
  static const butter = Color(0xFFFFE27A);
  static const peach = Color(0xFFFF9F7A);
  static const body = Color(0xFFE4DEFF);
  static const muted = Color(0xFFD4CBFA);
}

/// Main landing screen: animated card wall, headline and "Get started".
/// Navigation is handed in by the caller, so this screen stays standalone.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, this.onGetStarted, this.onSignIn});

  final VoidCallback? onGetStarted;
  final VoidCallback? onSignIn;

  static const _animationHeight = 1580.0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status bar icons, so they show on the purple background
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: WelcomeColors.bg,
      ),
      child: Scaffold(
        backgroundColor: WelcomeColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onSignIn: onSignIn),
              const SizedBox(height: 14),
              // Takes most of the free height. The animation (max 380) sits at
              // the bottom of it, so any spare room opens up between the
              // header and the animation and pushes the animation and the
              // headline down; on a short screen it just shrinks (cropped).
              Flexible(
                flex: 9,
                fit: FlexFit.tight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: _animationHeight,
                    ),
                    child: const _CardWallAnimation(),
                  ),
                ),
              ),
              const _Headline(),
              const Spacer(),
              _GetStarted(onPressed: onGetStarted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSignIn});

  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const AppLogo.mark(height: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Semester Forge',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: onSignIn,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: const StadiumBorder(),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1.5,
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}

/// The looping Lottie card wall, fading into the background at the bottom so
/// it melts into the headline below.
class _CardWallAnimation extends StatelessWidget {
  const _CardWallAnimation();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Clipped to its box and pinned to the bottom: on a short screen the
          // top row of the wall is cropped instead of spilling over the header
          ClipRect(
            child: Lottie.asset(
              'assets/animations/welcome_wall_card_1.json',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              repeat: true,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    WelcomeColors.bg.withValues(alpha: 0),
                    WelcomeColors.bg,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 36,
                height: 1.08,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: Colors.white,
              ),
              children: const [
                TextSpan(text: 'Your semester,\n'),
                TextSpan(
                  text: 'sorted.',
                  style: TextStyle(color: WelcomeColors.butter),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          const CustomPaint(
            size: Size(132, 12),
            painter: _SquigglePainter(WelcomeColors.peach),
          ),
          const SizedBox(height: 10),
          Text(
            'Pick your course once. Get every note, PYQ and syllabus for your '
            'semester in one place.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              height: 1.55,
              color: WelcomeColors.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _GetStarted extends StatelessWidget {
  const _GetStarted({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Column(
        children: [
          SizedBox(
            height: 54,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: WelcomeColors.ink.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: WelcomeColors.ink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Get started'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: WelcomeColors.muted,
              ),
              children: const [
                TextSpan(text: 'By continuing you agree to our '),
                TextSpan(
                  text: 'Terms',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Hand-drawn wavy line under "sorted."
class _SquigglePainter extends CustomPainter {
  const _SquigglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(2, 8)
      ..cubicTo(20, 2, 36, 2, 52, 7)
      ..cubicTo(68, 12, 86, 12, 102, 6)
      ..cubicTo(112, 2, 124, 2, 130, 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SquigglePainter old) => old.color != color;
}
