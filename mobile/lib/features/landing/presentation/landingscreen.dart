import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:lottie/lottie.dart';
import '../../Auth/presentation/loginscreen.dart';

/// Welcome (moving wall) screen wale colors
class _LandingColors {
  static const bg = Color(0xFF4B2BD6); // violet background
  static const ink = Color(0xFF140C2E); // dark text (button)
  static const butter = Color(0xFFFFE27A); // highlight text
  static const peach = Color(0xFFFF9F7A); // squiggle line
  static const body = Color(0xFFE4DEFF); // paragraph
  static const muted = Color(0xFFD4CBFA); // caption
  static const panel = Color(0xFFEEE9FF); // lottie ke peeche ka box
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // status bar ke icons white, violet bg pe dikhne ke liye
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _LandingColors.bg,
      ),
      child: Scaffold(
        backgroundColor: _LandingColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Header ----------
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/semesterforge_mark.svg',
                        height: 34,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Semester Forge',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _goToLogin(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.7),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // ---------- Lottie (unchanged) in a soft panel ----------
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: _LandingColors.panel,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/animations/landing_animation.json',
                    height: 190,
                    repeat: true,
                  ),
                ),

                const Spacer(flex: 2),

                // ---------- Heading ----------
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.displayBold.copyWith(
                      fontSize: 34,
                      height: 1.1,
                      letterSpacing: -0.8,
                      color: Colors.white,
                    ),
                    children: const [
                      TextSpan(text: 'Your resources,\n'),
                      TextSpan(
                        text: 'tailored to your semester.',
                        style: TextStyle(color: _LandingColors.butter),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const CustomPaint(
                  size: Size(132, 12),
                  painter: _SquigglePainter(_LandingColors.peach),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Direct access to curated class notes, previous year questions,'
                  ' and verified guides curated for your specific subject.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15,
                    height: 1.55,
                    color: _LandingColors.body,
                  ),
                ),

                const Spacer(flex: 2),

                // ---------- CTA ----------
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _goToLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _LandingColors.ink,
                      elevation: 6,
                      shadowColor: _LandingColors.ink.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'See How It Works',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _LandingColors.ink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'By continuing, you agree to our Terms and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: _LandingColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// heading ke neeche wali haath se khinchi line (welcome screen jaisi)
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