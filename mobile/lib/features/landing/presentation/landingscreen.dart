import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:lottie/lottie.dart';
import '../../auth/presentation/loginscreen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.iconBox),
                        ),
                        child: const Icon(Icons.school, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('StudyForge', style: AppTextStyles.bodySemiBold.copyWith(fontSize: 22)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text('Sign In', style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              Spacer(flex: 3),
              Lottie.asset(
                'assets/animations/landing_animation.json',
                height: 220,
                repeat: true,
              ),
              Spacer(flex: 1),
              Spacer(flex: 2),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.displayBold.copyWith(fontSize:50),
                  children: [
                    const TextSpan(text: 'Your campus, '),
                    TextSpan(text: 'tailored to your semester.',
                        style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Direct access to curated class notes, previous year questions,'
                    ' and verified guides curated for your specific subject.',
                style: AppTextStyles.bodyMedium.copyWith(fontSize:19),
              ),
              Spacer(flex: 2),
              AppButton(
                icon: Icons.arrow_forward,
                label: 'See How It Works',
                radius: 12,
                fontSize: 22,
                verticalPadding: 17,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'By continuing, you agree to our Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}