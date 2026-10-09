import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_picker_field.dart';
import 'signup_step_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../catalog/bloc/catalog_cubit.dart';
import '../../catalog/bloc/catalog_state.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/catalog_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/signup_draft.dart';

/// Creates the CatalogCubit for this screen and loads the universities.
/// The actual UI is in _SignupStep2View, which lives below the provider
/// so it can read the cubit.
class SignupStep2Screen extends StatelessWidget {
  const SignupStep2Screen({super.key, required this.draft});

  final SignupDraft draft;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CatalogCubit(context.read<CatalogRepository>())..start(),
      child: _SignupStep2View(draft: draft),
    );
  }
}

class _SignupStep2View extends StatefulWidget {
  const _SignupStep2View({required this.draft});

  final SignupDraft draft;

  @override
  State<_SignupStep2View> createState() => _SignupStep2ViewState();
}

class _SignupStep2ViewState extends State<_SignupStep2View> {
  int? _selectedSemester; // null until the user chooses
  bool _agreedToTerms = false;

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  void _submit() {
    final catalog = context.read<CatalogCubit>().state;

    if (!catalog.isComplete) {
      _showMessage('Please select your university, college and course');
      return;
    }
    final course = catalog.selectedCourse!;
    final semester = _selectedSemester;
    if (semester == null || semester > course.totalSemesters) {
      _showMessage('Please select your current semester');
      return;
    }
    if (!_agreedToTerms) {
      _showMessage('Please accept the terms to continue');
      return;
    }

    final draft = widget.draft;
    context.read<AuthBloc>().add(
      RegisterSubmitted(
        firstName: draft.firstName,
        lastName: draft.lastName,
        username: draft.username,
        email: draft.email,
        password: draft.password,
        universityId: catalog.selectedUniversity!.id,
        collegeId: catalog.selectedCollege!.id,
        courseId: course.id,
        currentSemester: semester,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Two listeners: register errors (AuthBloc) and loading errors (CatalogCubit).
    // On success nothing is needed here: main.dart's listener opens Home.
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) _showMessage(state.message);
          },
        ),
        BlocListener<CatalogCubit, CatalogState>(
          listenWhen: (previous, current) =>
              current.error != null && current.error != previous.error,
          listener: (context, state) {
            _showMessage(
              state.error!,
              // Nothing loaded at all: offer a retry
              action: state.universities.isEmpty
                  ? SnackBarAction(
                      label: 'Retry',
                      onPressed: () =>
                          context.read<CatalogCubit>().loadUniversities(),
                    )
                  : null,
            );
          },
        ),
      ],
      child: SignupStepScaffold(
        currentStep: 2,
        totalSteps: 2,
        title: 'Academic Details',
        subtitle: 'Step 2 of 2: Connect your campus curriculum',
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, catalog) => _buildForm(context, catalog),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CatalogState catalog) {
    final cubit = context.read<CatalogCubit>();
    // The semester grid follows the chosen course (8 until one is chosen)
    final totalSemesters = catalog.selectedCourse?.totalSemesters ?? 8;
    final selectedSemester =
        (_selectedSemester != null && _selectedSemester! <= totalSemesters)
        ? _selectedSemester
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPickerField<University>(
                label: 'University',
                hint: 'Select your university',
                items: catalog.universities,
                value: catalog.selectedUniversity,
                itemLabel: (u) => '${u.name} (${u.shortName})',
                onSelected: cubit.selectUniversity,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPickerField<College>(
                label: 'College / Institute',
                hint: 'Select your college',
                items: catalog.colleges,
                value: catalog.selectedCollege,
                itemLabel: (c) => c.name,
                enabled: catalog.selectedUniversity != null,
                onSelected: cubit.selectCollege,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPickerField<Course>(
                label: 'Course / Degree',
                hint: 'Select your course',
                items: catalog.courses,
                value: catalog.selectedCourse,
                itemLabel: (c) => c.name,
                enabled: catalog.selectedUniversity != null,
                onSelected: cubit.selectCourse,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPickerField<int>(
                label: 'Current Semester',
                hint: 'Select your semester',
                items: List.generate(totalSemesters, (i) => i + 1),
                value: selectedSemester,
                itemLabel: (s) => 'Semester $s',
                onSelected: (s) => setState(() => _selectedSemester = s),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (value) =>
                        setState(() => _agreedToTerms = value ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium,
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text:
                                  'Terms of Service & Campus Academic Honor Code',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, auth) {
            final isLoading = auth is AuthLoading;
            return AppButton(
              label: isLoading ? 'Creating account...' : 'Complete Setup',
              icon: isLoading ? null : Icons.arrow_forward,
              fontSize: 18,
              radius: 0,
              verticalPadding: 13,
              onPressed: isLoading ? null : _submit,
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text('Back to Step 1', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
