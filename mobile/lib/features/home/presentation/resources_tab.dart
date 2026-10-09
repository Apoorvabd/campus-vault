import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/profile.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/subject_tile.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../resources/bloc/resources_tab_cubit.dart';
import '../../resources/bloc/resources_tab_state.dart';
import '../../subject/presentation/subject_detail_screen.dart';
import '../../subject/subject_style.dart';
import '../../../core/widgets/skeleton.dart';

/// Resources tab content: "Your Subjects" for the user's current semester.
/// Scrolls on its own: it is a page of Home's swipeable tab view.
class ResourcesTab extends StatelessWidget {
  const ResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // The profile may still be loading when the tab first shows. The tab
    // scrolls on its own, so Home can swipe between the two tabs.
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [_content()],
    );
  }

  Widget _content() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;
        if (profile == null) {
          return profileState.error != null
              ? ErrorView(
                  message: profileState.error!,
                  onRetry: () => context.read<ProfileCubit>().load(),
                )
              : const SkeletonSubjectList();
        }
        // A new cubit (and so a reload) only when course/semester change
        return BlocProvider(
          key: ValueKey(
            '${profile.courseId}-${profile.currentSemester}-${profile.subjectsConfirmedAt}',
          ),
          create: (context) =>
              ResourcesTabCubit(context.read<SubjectsRepository>())..load(),
          child: _ResourcesContent(profile: profile),
        );
      },
    );
  }
}

class _ResourcesContent extends StatelessWidget {
  const _ResourcesContent({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResourcesTabCubit>();
    final sem = profile.currentSemester;

    return BlocBuilder<ResourcesTabCubit, ResourcesTabState>(
      builder: (context, state) {
        if (state.isLoading) return const SkeletonSubjectList();
        if (state.error != null) {
          return ErrorView(message: state.error!, onRetry: cubit.load);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: 'Your Subjects', trailing: 'Semester $sem'),
            const SizedBox(height: AppSpacing.md),
            if (state.subjects.isEmpty)
              const EmptyView(
                title: 'No subjects yet',
                message: 'No subjects are listed for your semester.',
                icon: Icons.menu_book_outlined,
              ),
            for (final subject in state.subjects) ...[
              Builder(
                builder: (context) {
                  final style = SubjectStyle.of(subject);
                  return SubjectTile(
                    icon: style.icon,
                    iconColor: style.color,
                    title: subject.name,
                    subtitle: '${subject.code} · ${subject.type}',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubjectDetailScreen(subject: subject),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
