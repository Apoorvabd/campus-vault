import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import 'signup_step_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../catalog/data/catalog_repository.dart';
import '../data/signup_draft.dart';
import './registration_step2_screen.dart';

class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  bool _obscurePassword = true;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start fetching Delhi University's colleges and courses now, so step 2
    // opens with them already in place
    context.read<CatalogRepository>().warmUp();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Returns the first problem found, or null when everything is valid.
  /// The rules mirror the backend's registerSchema, so we fail fast
  /// without a network call.
  String? _validate() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (firstName.length < 3) {
      return 'First name must be at least 3 characters';
    }
    if (lastName.isNotEmpty && lastName.length < 3) {
      return 'Last name must be at least 3 characters';
    }
    if (username.isNotEmpty) {
      if (username.length < 3 || username.length > 30) {
        return 'Username must be 3 to 30 characters';
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        return 'Username can only have letters, numbers and underscores';
      }
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _next() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Empty optional fields become null so they are not sent to the backend
    String? nullIfEmpty(String text) =>
        text.trim().isEmpty ? null : text.trim();

    final draft = SignupDraft(
      firstName: _firstNameController.text.trim(),
      lastName: nullIfEmpty(_lastNameController.text),
      username: nullIfEmpty(_usernameController.text),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupStep2Screen(draft: draft)),
    );
  }

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
                    Expanded(
                      child: AppTextField(
                        label: 'First Name',
                        hint: 'e.g. Alex',
                        controller: _firstNameController,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: 'Last Name',
                        hint: 'e.g. Sharma',
                        controller: _lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Username (optional)',
                  hint: 'We will pick one if you skip',
                  controller: _usernameController,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email Address',
                  hint: 'e.g. alex@university.edu',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Next Step',
                  icon: Icons.arrow_forward,
                  fontSize: 16,
                  radius: 8,
                  onPressed: _next,
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
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
