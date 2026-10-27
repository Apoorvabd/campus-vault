import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../Auth/data/auth_repository.dart';

/// Change password for a logged-in user. Other devices get logged out; this one
/// stays logged in.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    // The button and the mismatch hint follow what is typed
    for (final controller in [
      _currentController,
      _newController,
      _confirmController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _passwordsMatch => _newController.text == _confirmController.text;

  bool get _canSubmit =>
      !_isBusy &&
      _currentController.text.isNotEmpty &&
      _newController.text.length >= 8 &&
      _passwordsMatch;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final repository = context.read<AuthRepository>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isBusy = true);
    try {
      await repository.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Password changed')));
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        e is ApiException
            ? e.message
            : 'Something went wrong. Please try again.',
      );
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMismatch = _confirmController.text.isNotEmpty && !_passwordsMatch;
    final eye = _obscure ? Icons.visibility_off : Icons.visibility;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Change your password', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Other devices will be logged out. This device stays logged in.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Current Password',
                      hint: 'Enter your current password',
                      controller: _currentController,
                      obscureText: _obscure,
                      suffixIcon: eye,
                      onSuffixTap: () => setState(() => _obscure = !_obscure),
                      enabled: !_isBusy,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'New Password',
                      hint: 'At least 8 characters',
                      controller: _newController,
                      obscureText: _obscure,
                      enabled: !_isBusy,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Confirm New Password',
                      hint: 'Type it again',
                      controller: _confirmController,
                      obscureText: _obscure,
                      enabled: !_isBusy,
                    ),
                    if (showMismatch) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Passwords do not match',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: _isBusy ? 'Updating...' : 'Update password',
                      fontSize: 16,
                      radius: 8,
                      onPressed: _canSubmit ? _submit : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
