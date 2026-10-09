import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_picker_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/subjects_setup_cubit.dart';
import '../../../core/widgets/skeleton.dart';

// Stands for "no subject" in the pickers (the picker can't return null)
const _none = Subject(
  id: '',
  name: 'None',
  code: '',
  type: '',
  courseId: '',
);

// Second line in the pickers. GE names repeat across departments, so show which
// department offers it; the shared SEC / VAC / AEC lists need no extra line.
String? _subtitle(Subject s) => s.type == 'GE' ? s.courseName : null;

/// "Your subjects" form: confirm the DSC subjects and pick GE / DSE / SEC /
/// VAC / AEC from dropdowns. Shown right after sign-up and from Profile.
class SubjectsSetupScreen extends StatelessWidget {
  const SubjectsSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubjectsSetupCubit(context.read<SubjectsRepository>()),
      child: const _SetupView(),
    );
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView();

  Future<bool> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave without saving?'),
        content: const Text(
          'Your subjects won\'t be set up. You can finish this later from Profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<SubjectsSetupCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (!await cubit.save()) return;
    await profileCubit.load(); // refreshes the "Setup needed" badge and Home
    messenger.showSnackBar(const SnackBar(content: Text('Subjects saved')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubjectsSetupCubit>().state;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmLeave(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Your subjects'),
        ),
        body: state.isLoading
            ? const SkeletonForm()
            : state.error != null
                ? ErrorView(
                    message: state.error!,
                    onRetry: () => context.read<SubjectsSetupCubit>().load(),
                  )
                : _Form(onSave: () => _save(context)),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SubjectsSetupCubit>();
    final state = context.watch<SubjectsSetupCubit>().state;
    final form = state.form!;

    Widget required(
      String label,
      List<Subject> options,
      String? value,
      ValueChanged<String?> onChanged,
    ) =>
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppPickerField<Subject>(
            label: label,
            hint: 'Select subject',
            items: options,
            itemLabel: (s) => s.name,
            itemSubtitle: _subtitle,
            value: cubit.subjectById(value),
            onSelected: (s) => onChanged(s.id),
          ),
        );

    Widget optional(
      String label,
      List<Subject> options,
      String? value,
      ValueChanged<String?> onChanged,
    ) =>
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppPickerField<Subject>(
            label: '$label (optional)',
            hint: 'None',
            items: [_none, ...options],
            itemLabel: (s) => s.name,
            itemSubtitle: _subtitle,
            value: cubit.subjectById(value),
            onSelected: (s) => onChanged(s.id.isEmpty ? null : s.id),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Semester ${form.semester}', style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        Text('CORE SUBJECTS (DSC)', style: AppTextStyles.overline),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'We filled these in for you. Change any that look wrong.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 3; i++)
          required('DSC ${i + 1}', form.optionsFor('dsc'), state.dsc[i],
              (id) => cubit.setDsc(i, id)),
        const SizedBox(height: AppSpacing.md),
        Text('OTHER SUBJECTS', style: AppTextStyles.overline),
        const SizedBox(height: AppSpacing.sm),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          title: Text(
            'I don\'t have a GE this semester',
            style: AppTextStyles.bodyMedium,
          ),
          value: state.noGe,
          onChanged: (v) => cubit.setNoGe(v ?? false),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!state.noGe)
          optional('GE', form.optionsFor('ge'), state.ge, cubit.setGe),
        optional('DSE', form.optionsFor('dse'), state.dse[0],
            (id) => cubit.setDse(0, id)),
        if (state.noGe)
          optional('DSE 2', form.optionsFor('dse'), state.dse[1],
              (id) => cubit.setDse(1, id)),
        optional('SEC', form.optionsFor('sec'), state.sec, cubit.setSec),
        optional('VAC', form.optionsFor('vac'), state.vac, cubit.setVac),
        optional('AEC', form.optionsFor('aec'), state.aec, cubit.setAec),
        if (state.formError != null) ...[
          Text(
            state.formError!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppButton(
          label: state.isSaving ? 'Saving...' : 'Save subjects',
          onPressed: state.isSaving ? null : onSave,
        ),
        // Deliberately small and quiet: skipping is possible, not encouraged
        Center(
          child: TextButton(
            onPressed: state.isSaving
                ? null
                : () => Navigator.of(context).maybePop(),
            child: Text(
              'Skip for now',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
