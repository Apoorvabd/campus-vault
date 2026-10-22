import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/auth_repository.dart';

enum _Phase { idle, sending, codeSent, verifying, verified }

/// The signup email field with its OTP check built in: a valid email shows
/// "Send OTP", the code box appears below it, and typing the 6th digit
/// verifies on its own. Once verified the email is locked (until "Change").
class EmailOtpSection extends StatefulWidget {
  const EmailOtpSection({
    super.key,
    required this.emailController,
    required this.onVerifiedChanged,
  });

  final TextEditingController emailController;

  /// The proof when the email gets verified, null when it stops being verified.
  final ValueChanged<String?> onVerifiedChanged;

  @override
  State<EmailOtpSection> createState() => _EmailOtpSectionState();
}

class _EmailOtpSectionState extends State<EmailOtpSection> {
  final _otpController = TextEditingController();
  _Phase _phase = _Phase.idle;
  Timer? _timer;
  int _secondsLeft = 0;
  late String _lastEmail;

  @override
  void initState() {
    super.initState();
    _lastEmail = widget.emailController.text;
    widget.emailController.addListener(_onEmailChanged);
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    widget.emailController.removeListener(_onEmailChanged);
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _email => widget.emailController.text.trim();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // The listener also fires for cursor moves; only a real edit matters
  void _onEmailChanged() {
    final email = widget.emailController.text;
    if (email == _lastEmail) return;
    _lastEmail = email;
    _reset();
  }

  void _onOtpChanged() {
    if (_phase == _Phase.codeSent && _otpController.text.length == 6) {
      _verify();
    }
  }

  /// Back to the start: a different email needs its own code.
  void _reset() {
    final wasVerified = _phase == _Phase.verified;
    _timer?.cancel();
    _secondsLeft = 0;
    _otpController.clear();
    setState(() => _phase = _Phase.idle);
    if (wasVerified) widget.onVerifiedChanged(null);
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
    final previous = _phase;
    setState(() => _phase = _Phase.sending);
    try {
      final cooldown = await repository.sendEmailCode(_email);
      if (!mounted) return;
      setState(() => _phase = _Phase.codeSent);
      _startCooldown(cooldown);
    } catch (e) {
      if (!mounted) return;
      setState(() => _phase = previous);
      _showMessage(_errorMessage(e));
    }
  }

  Future<void> _verify() async {
    final repository = context.read<AuthRepository>();
    setState(() => _phase = _Phase.verifying);
    try {
      final proof = await repository.verifyEmailCode(
        email: _email,
        code: _otpController.text,
      );
      if (!mounted) return;
      _timer?.cancel();
      setState(() => _phase = _Phase.verified);
      widget.onVerifiedChanged(proof);
    } catch (e) {
      if (!mounted) return;
      // Stay on the code box: after too many wrong tries or an expired code,
      // "Resend OTP" gets a fresh one
      _otpController.clear();
      setState(() => _phase = _Phase.codeSent);
      _showMessage(_errorMessage(e));
    }
  }

  String _errorMessage(Object error) => error is ApiException
      ? error.message
      : 'Something went wrong. Please try again.';

  @override
  Widget build(BuildContext context) {
    final isVerified = _phase == _Phase.verified;
    final showCodeBox =
        _phase == _Phase.codeSent || _phase == _Phase.verifying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Email Address',
          hint: 'e.g. alex@university.edu',
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: _phase == _Phase.idle || _phase == _Phase.codeSent,
        ),
        if (isVerified)
          _VerifiedRow(onChange: _reset)
        else if (isValidEmail(_email))
          _sendLink(),
        if (showCodeBox) ...[
          const SizedBox(height: AppSpacing.xs),
          AppTextField(
            label: 'Enter OTP',
            hint: '6-digit code',
            controller: _otpController,
            keyboardType: TextInputType.number,
            enabled: _phase == _Phase.codeSent,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ],
      ],
    );
  }

  Widget _sendLink() {
    final isSending = _phase == _Phase.sending;
    final isWaiting = _phase == _Phase.codeSent && _secondsLeft > 0;
    final canTap = !isSending && !isWaiting && _phase != _Phase.verifying;

    final String label;
    if (_phase == _Phase.idle || isSending) {
      label = 'Send OTP';
    } else if (isWaiting) {
      label = 'Resend OTP in ${_secondsLeft}s';
    } else {
      label = 'Resend OTP';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: canTap ? _sendCode : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: isSending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _VerifiedRow extends StatelessWidget {
  const _VerifiedRow({required this.onChange});

  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Email verified',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
