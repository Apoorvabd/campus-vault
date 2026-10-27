import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/auth_repository.dart';

enum _Stage { email, code, newPassword }

// "Resend OTP" opens this many seconds after the server's own cooldown, so a
// slow network never trips the server's limit
const _networkBufferSeconds = 5;

/// Forgot password in three stages on one screen: email, the emailed code, then
/// the new password. Pops with `true` once the password was reset.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _Stage _stage = _Stage.email;
  bool _isBusy = false;
  bool _obscurePassword = true;
  String? _resetProof;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object error) => error is ApiException
      ? error.message
      : 'Something went wrong. Please try again.';

  void _onOtpChanged() {
    if (_stage == _Stage.code && !_isBusy && _otpController.text.length == 6) {
      _verifyCode();
    }
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _sendCode() async {
    if (!isValidEmail(_email)) {
      _showMessage('Fill correct email');
      return;
    }
    final repository = context.read<AuthRepository>();
    setState(() => _isBusy = true);
    try {
      final cooldown = await repository.sendPasswordResetCode(_email);
      if (!mounted) return;
      _showMessage('If this email has an account, a code is on its way.');
      setState(() => _stage = _Stage.code);
      _startCooldown(cooldown + _networkBufferSeconds);
    } catch (e) {
      if (mounted) _showMessage(_errorMessage(e));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _verifyCode() async {
    final repository = context.read<AuthRepository>();
    setState(() => _isBusy = true);
    try {
      final proof = await repository.verifyPasswordResetCode(
        email: _email,
        code: _otpController.text,
      );
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _resetProof = proof;
        _stage = _Stage.newPassword;
      });
    } catch (e) {
      if (!mounted) return;
      // Stay on the code box: after too many wrong tries or an expired code,
      // "Resend OTP" gets a fresh one
      _otpController.clear();
      _showMessage(_errorMessage(e));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters');
      return;
    }
    if (password != _confirmController.text) {
      _showMessage('Passwords do not match');
      return;
    }
    final repository = context.read<AuthRepository>();
    final navigator = Navigator.of(context);
    setState(() => _isBusy = true);
    try {
      await repository.resetPassword(
        email: _email,
        resetProof: _resetProof!,
        newPassword: password,
      );
      // The login screen tells the user it worked
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(_errorMessage(e));
      setState(() => _isBusy = false);
    }
  }

  /// Back to the email step, e.g. to fix a typo.
  void _changeEmail() {
    _timer?.cancel();
    _otpController.clear();
    setState(() {
      _secondsLeft = 0;
      _stage = _Stage.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/images/semesterforge_logo_full.svg',
                  height: 110,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(_title, style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(_subtitle, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: switch (_stage) {
                    _Stage.email => _emailStage(),
                    _Stage.code => _codeStage(),
                    _Stage.newPassword => _newPasswordStage(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title => switch (_stage) {
    _Stage.email => 'Reset your password',
    _Stage.code => 'Enter the code',
    _Stage.newPassword => 'Create a new password',
  };

  String get _subtitle => switch (_stage) {
    _Stage.email =>
      'Enter the email of your account and we will send you a 6-digit code.',
    _Stage.code =>
      'We sent a 6-digit code to the email below. It is valid for 5 minutes.',
    _Stage.newPassword => 'Choose a password of at least 8 characters.',
  };

  List<Widget> _emailStage() => [
    AppTextField(
      label: 'Email Address',
      hint: 'e.g. alex@university.edu',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !_isBusy,
    ),
    const SizedBox(height: AppSpacing.lg),
    AppButton(
      label: _isBusy ? 'Sending...' : 'Send code',
      fontSize: 16,
      radius: 8,
      onPressed: _isBusy ? null : _sendCode,
    ),
  ];

  List<Widget> _codeStage() {
    final isWaiting = _secondsLeft > 0;
    return [
      AppTextField(
        label: 'Email Address',
        controller: _emailController,
        enabled: false,
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: _isBusy ? null : _changeEmail,
          style: _linkStyle,
          child: const Text('Change email'),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'Enter OTP',
        hint: '6-digit code',
        controller: _otpController,
        keyboardType: TextInputType.number,
        enabled: !_isBusy,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: _isBusy || isWaiting ? null : _sendCode,
          style: _linkStyle,
          child: Text(
            isWaiting ? 'Resend OTP in ${_secondsLeft}s' : 'Resend OTP',
          ),
        ),
      ),
    ];
  }

  List<Widget> _newPasswordStage() => [
    AppTextField(
      label: 'New Password',
      hint: 'At least 8 characters',
      controller: _passwordController,
      obscureText: _obscurePassword,
      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
      onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
      enabled: !_isBusy,
    ),
    const SizedBox(height: AppSpacing.md),
    AppTextField(
      label: 'Confirm Password',
      hint: 'Type it again',
      controller: _confirmController,
      obscureText: _obscurePassword,
      enabled: !_isBusy,
    ),
    const SizedBox(height: AppSpacing.lg),
    AppButton(
      label: _isBusy ? 'Updating...' : 'Reset password',
      fontSize: 16,
      radius: 8,
      onPressed: _isBusy ? null : _resetPassword,
    ),
    const SizedBox(height: AppSpacing.sm),
    Text(
      'You will be logged out of all devices and asked to log in again.',
      style: AppTextStyles.caption,
    ),
  ];

  static final _linkStyle = TextButton.styleFrom(
    padding: const EdgeInsets.only(top: AppSpacing.xs),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
