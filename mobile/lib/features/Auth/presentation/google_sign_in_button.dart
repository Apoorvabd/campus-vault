import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../data/auth_repository.dart';
import '../data/signup_draft.dart';
import 'registration_step2_screen.dart';

/// "Login with Google", used on the login screen and on signup step 1.
/// An existing account is logged in straight away; a new Google user goes on
/// to step 2 to give the academic details (name and email come from Google).
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isBusy = false;

  Future<void> _signIn() async {
    final repository = context.read<AuthRepository>();
    final authBloc = context.read<AuthBloc>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isBusy = true);
    try {
      final idToken = await repository.getGoogleIdToken();
      if (idToken == null) return; // the picker was closed

      final result = await repository.loginWithGoogle(idToken);
      final profile = result.signupProfile;
      if (profile == null) {
        // main.dart's listener opens Home
        authBloc.add(GoogleLoggedIn(result.user!));
        return;
      }

      navigator.push(
        MaterialPageRoute(
          builder: (_) => SignupStep2Screen(
            draft: SignupDraft.google(
              firstName: profile.firstName,
              lastName: profile.lastName,
              email: profile.email,
              googleIdToken: idToken,
            ),
          ),
        ),
      );
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException
                  ? e.message
                  : 'Something went wrong. Please try again.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _isBusy ? 'Please wait...' : 'Login with Google',
      variant: AppButtonVariant.outline,
      icon: Icons.g_mobiledata,
      fontSize: 15,
      radius: 8,
      onPressed: _isBusy ? null : _signIn,
    );
  }
}
