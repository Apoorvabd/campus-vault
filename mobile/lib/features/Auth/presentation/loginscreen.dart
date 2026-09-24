import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../Auth/presentation/registration_step1_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberDevice = true;

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
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.iconBox),
                  ),
                  child: const Icon(Icons.school, color: AppColors.primary, size: 32),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Sign in to Campus Vault',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(fontSize:30),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Enter your  credentials to continue',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(fontSize:18),
              ),
              const SizedBox(height: AppSpacing.xl),
              // yahan aage build karenge
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppTextField(
                      label: 'Email or UserName',
                      hint: 'e.g., abd!@#12 or student@gmail.com',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      trailingLabel: 'Forgot password?',
                      onTrailingLabelTap: () {
                        // TODO: navigate to forgot password screen
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberDevice,
                          activeColor: AppColors.primary,
                          onChanged: (value) => setState(() => _rememberDevice = value ?? false),
                        ),
                        Text('Remember this device', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Sign In',
                      fontSize:22,
                      radius:8,
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupStep1Screen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('OR CONTINUE WITH', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: 'Google Workspace SSO',
                variant: AppButtonVariant.outline,
                icon: Icons.g_mobiledata,
                fontSize:20,
                radius:8,
                onPressed: () {
                  // TODO: Google SSO flow
                },
              ),
              const SizedBox(height:80),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupStep1Screen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium,
                      children: [
                        const TextSpan(text: "Don't have an account? "),

                        TextSpan(
                          text: 'Register with email. →',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('256-bit encrypted academic session', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}