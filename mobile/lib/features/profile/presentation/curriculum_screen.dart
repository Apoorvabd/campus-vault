import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/profile.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_picker_field.dart';
import '../../../core/widgets/state_views.dart';
import '../bloc/curriculum_cubit.dart';
import '../bloc/profile_cubit.dart';
import '../../../core/widgets/skeleton.dart';

/// Curriculum & Semester: the academic profile (read-only) plus a semester
/// picker. Saving updates the user's current semester on the server, which
/// also decides which subjects the Resources tab shows.
class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state.profile;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Curriculum & Semester'),
      ),
      body: profile == null
          ? const SkeletonForm(fields: 3)
          : BlocProvider(
              // one Cubit per visit; it loads the subjects of the chosen semester
              create: (context) => CurriculumCubit(
                context.read<SubjectsRepository>(),
                courseId: profile.courseId,
                semester: profile.currentSemester,
              ),
              child: _CurriculumView(profile: profile),
            ),
    );
  }
}

class _CurriculumView extends StatelessWidget {
  const _CurriculumView({required this.profile});

  final Profile profile;

  Future<void> _save(BuildContext context, int semester) async {
    final profileCubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await profileCubit.update(currentSemester: semester);
    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text('Semester set to $semester')),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(profileCubit.state.error ?? 'Could not save')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<ProfileCubit>().state.isSaving;
    final curriculum = context.watch<CurriculumCubit>().state;
    final semesters = List.generate(profile.totalSemesters ?? 8, (i) => i + 1);
    final changed = curriculum.selectedSemester != profile.currentSemester;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('ACADEMIC PROFILE', style: AppTextStyles.overline),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.account_balance_outlined,
                label: 'University',
                value: profile.universityName,
              ),
              const Divider(height: 1, color: AppColors.border),
              _InfoRow(
                icon: Icons.apartment_outlined,
                label: 'College',
                value: profile.collegeName,
              ),
              const Divider(height: 1, color: AppColors.border),
              _InfoRow(
                icon: Icons.school_outlined,
                label: 'Course',
                value: profile.courseName,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPickerField<int>(
          label: 'Current Semester',
          hint: 'Select semester',
          items: semesters,
          value: curriculum.selectedSemester,
          itemLabel: (s) => 'Semester $s',
          onSelected: context.read<CurriculumCubit>().selectSemester,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'SUBJECTS IN SEMESTER ${curriculum.selectedSemester}',
          style: AppTextStyles.overline,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (curriculum.isLoading)
          const SkeletonSubjectList(count: 3)
        else if (curriculum.error != null)
          ErrorView(
            message: curriculum.error!,
            onRetry: () => context.read<CurriculumCubit>().selectSemester(
              curriculum.selectedSemester,
            ),
          )
        else if (curriculum.subjects.isEmpty)
          AppCard(
            child: Text(
              'Subjects for this semester will appear here once they are added to your course.',
              style: AppTextStyles.bodyMedium,
            ),
          )
        else
          for (final subject in curriculum.subjects) ...[
            _SubjectRow(subject: subject),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: saving
              ? 'Saving...'
              : (changed ? 'Save Changes' : 'Up to date'),
          onPressed: changed && !saving
              ? () => _save(context, curriculum.selectedSemester)
              : null,
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    // Colour is UI-only: pick one per subject from the palette
    final palette = AppColors.avatarPalette;
    final color = palette[subject.name.hashCode.abs() % palette.length];

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.iconBox),
            ),
            child: Icon(Icons.menu_book_outlined, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                ),
                Text(
                  '${subject.code} · ${subject.type}',
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
