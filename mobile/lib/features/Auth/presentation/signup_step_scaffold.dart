import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/progress_step_header.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared shell for the signup flow — AppBar, back button, progress
/// header and heading are identical across Step 1 and Step 2; only the
/// form content (`child`) changes between them.
class SignupStepScaffold extends StatelessWidget {
  const SignupStepScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Create Your Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: SvgPicture.asset(
                  'assets/images/semesterforge_logo_full.svg',
                  height: 130,
                ),
              ),
              ProgressStepHeader(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Text(title, style: AppTextStyles.h1),
              // const SizedBox(height: AppSpacing.xs),
              // Text(subtitle, style: AppTextStyles.bodyMedium),
              // const SizedBox(height: AppSpacing.xl),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
