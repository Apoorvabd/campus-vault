import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/progress_step_header.dart';
import '../../../core/widgets/floating_icon.dart';

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
        title: const Text('Campus Vault'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProgressStepHeader(currentStep: currentStep, totalSteps: totalSteps),
              const SizedBox(height: AppSpacing.lg),
              const Center(child: FloatingIcon(icon: Icons.school, size: 80)),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              child,
            ],
          ),
        ),
      ),
    );
  }
}