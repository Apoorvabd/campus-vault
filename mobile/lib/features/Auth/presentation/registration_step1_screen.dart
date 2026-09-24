import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import 'signup_step_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import './registration_step2_screen.dart';


class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return SignupStepScaffold(
      currentStep: 1,
      totalSteps: 2,
      title: 'Create your Account',
      subtitle: 'Step 1 of 2: Your identity & credentials',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: AppTextField(label: 'First Name', hint: 'e.g. Alex')),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(child: AppTextField(label: 'Last Name', hint: 'e.g. Sharma')),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(label: 'Username', hint: 'e.g. alexsharma'),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(
                  label: 'Email Address',
                  hint: 'e.g. alex@university.edu',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Next Step',
                  icon: Icons.arrow_forward,
                  fontSize:22,
                  radius:8,
                 onPressed: () {
                      Navigator.push(
                          context,
                           MaterialPageRoute(builder: (context) => const SignupStep2Screen()),
                      );
},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium,
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
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