import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../bloc/profile_cubit.dart';

/// Bottom sheet to change the profile photo and edit name, username,
/// headline and bio. Talks to the app-wide [ProfileCubit].
Future<void> showEditProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _EditProfileSheet(),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _username;
  late final TextEditingController _headline;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    // The sheet only opens when the profile is loaded
    final profile = context.read<ProfileCubit>().state.profile!;
    _firstName = TextEditingController(text: profile.firstName);
    _lastName = TextEditingController(text: profile.lastName ?? '');
    _username = TextEditingController(text: profile.username);
    _headline = TextEditingController(text: profile.headline ?? '');
    _bio = TextEditingController(text: profile.bio ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _headline.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Same rules as the backend's updateProfileSchema.
  String? _validate() {
    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    final username = _username.text.trim();
    if (first.length < 3) return 'First name must be at least 3 characters';
    if (last.isNotEmpty && last.length < 3) {
      return 'Last name must be at least 3 characters';
    }
    if (username.length < 3 || username.length > 30) {
      return 'Username must be 3 to 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only have letters, numbers and underscores';
    }
    if (_headline.text.trim().length > 120) {
      return 'Headline can be at most 120 characters';
    }
    if (_bio.text.trim().length > 500) return 'Bio can be at most 500 characters';
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) return _showMessage(error);

    final cubit = context.read<ProfileCubit>();
    final navigator = Navigator.of(context);
    final ok = await cubit.update(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      username: _username.text.trim(),
      headline: _headline.text.trim(),
      bio: _bio.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      navigator.pop();
    } else {
      _showMessage(cubit.state.error ?? 'Could not save your profile');
    }
  }

  Future<void> _pickAvatar() async {
    final cubit = context.read<ProfileCubit>();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final ok = await cubit.setAvatar(picked.path);
    if (!ok && mounted) {
      _showMessage(cubit.state.error ?? 'Could not upload the photo');
    }
  }

  Future<void> _removeAvatar() async {
    final cubit = context.read<ProfileCubit>();
    final ok = await cubit.removeAvatar();
    if (!ok && mounted) {
      _showMessage(cubit.state.error ?? 'Could not remove the photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // lift the sheet above the keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final Profile? profile = state.profile;
          final busy = state.isSaving;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit profile', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    AvatarCircle(
                      name: profile?.fullName ?? '',
                      size: 64,
                      imageUrl: profile?.avatarUrl,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          OutlinedButton.icon(
                            onPressed: busy ? null : _pickAvatar,
                            icon: const Icon(Icons.photo_outlined, size: 18),
                            label: const Text('Change photo'),
                          ),
                          if (profile?.avatarUrl != null)
                            TextButton(
                              onPressed: busy ? null : _removeAvatar,
                              child: const Text(
                                'Remove',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First Name',
                        controller: _firstName,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: 'Last Name',
                        controller: _lastName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Username', controller: _username),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Headline',
                  hint: 'e.g. CS student · notes enthusiast',
                  controller: _headline,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Bio',
                  hint: 'A line or two about you',
                  controller: _bio,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: busy ? 'Saving...' : 'Save changes',
                  fontSize: 16,
                  radius: 8,
                  onPressed: busy ? null : _save,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          );
        },
      ),
    );
  }
}
