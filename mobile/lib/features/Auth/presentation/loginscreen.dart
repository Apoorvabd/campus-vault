import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../Auth/presentation/registration_step1_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberDevice = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controllers hold resources; release them when the screen is destroyed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Same rules as the backend, so we fail fast without a network call
    if (!email.contains('@')) {
      _showMessage('Enter a valid email address');
      return;
    }
    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters');
      return;
    }

    FocusScope.of(context).unfocus(); // hide the keyboard
    context.read<AuthBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Success needs no code here: main.dart's listener navigates to Home
        // Only when this screen is on top (signup screens may be open above it)
        if (state is AuthFailure && ModalRoute.of(context)?.isCurrent == true) {
          _showMessage(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Sign In'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: SvgPicture.asset(
                    'assets/images/semesterforge_logo_full.svg',
                    height: 130,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Text(
                //   'Sign in to Semester Forge',
                //   textAlign: TextAlign.center,
                //   style: AppTextStyles.h1.copyWith(fontSize: 25),
                // ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Welcome back! Please sign in to continue.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.lg),
                // yahan aage build karenge
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Email ',
                          hint: 'e.g. student@gmail.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          compact: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          compact: true,
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onSuffixTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
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
                              onChanged: (value) => setState(
                                () => _rememberDevice = value ?? false,
                              ),
                            ),
                            Text(
                              'Remember this device',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return AppButton(
                              label: isLoading ? 'Signing in...' : 'Sign In',
                              fontSize: 16,
                              radius: 8,
                              icon: isLoading ? null : Icons.arrow_forward,
                              onPressed: isLoading
                                  ? null
                                  : _submit, // null disables the button
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color.fromARGB(255, 26, 94, 182)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: const Color.fromARGB(255, 25, 73, 138),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color.fromARGB(255, 30, 97, 185)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Google Workspace SSO',
                  variant: AppButtonVariant.outline,
                  icon: Icons.g_mobiledata,
                  fontSize: 15,
                  radius: 8,
                  onPressed: () {
                    // TODO: Google SSO flow
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupStep1Screen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium,
                        children: [
                          const TextSpan(text: "Don't have an account? "),

                          TextSpan(
                            text: 'Register with email. →',
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
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '256-bit encrypted academic session',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
