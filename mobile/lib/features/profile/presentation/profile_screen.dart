import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../subjects/presentation/subjects_setup_screen.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/models/profile.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../core/widgets/state_views.dart';
import '../../Auth/bloc/auth_bloc.dart';
import '../../Auth/bloc/auth_event.dart';
import '../bloc/profile_cubit.dart';
import 'edit_profile_sheet.dart';
import '../../support/presentation/help_center_screen.dart';
import 'contributor_badges_screen.dart';
import 'curriculum_screen.dart';
import 'honor_code_screen.dart';
import 'my_requests_screen.dart';
import 'storage_cache_screen.dart';
import '../../support/presentation/privacy_terms_screen.dart';
import '../../../core/widgets/skeleton.dart';

/// Account Settings screen — opened from the bottom nav's Profile tab.
/// Matches the Stitch "Account Settings" design.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _navIndex = 4;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to use Semester Forge.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    // main.dart's listener sends the user to the landing screen
    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds whenever the ProfileCubit emits (load, edit, new avatar)
    final profileState = context.watch<ProfileCubit>().state;
    final profile = profileState.profile;

    return AppShellScaffold(
      currentIndex: _navIndex,
      onSearchTap: () => openSearch(context),
      onNavTap: (index) {
        if (index == _navIndex) return;
        goToTab(context, index);
      },
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Account Settings', style: AppTextStyles.h1),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: AppColors.textPrimary,
                    ),
                    // Bookmarks live on the Saved tab
                    onPressed: () => goToTab(context, 3),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AvatarCircle(
                    name: profile?.fullName ?? '',
                    size: 32,
                    imageUrl: profile?.avatarUrl,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (profile != null)
            _ProfileCard(profile: profile)
          else if (profileState.error != null)
            ErrorView(
              message: profileState.error!,
              onRetry: () => context.read<ProfileCubit>().load(),
            )
          else
            const SkeletonProfileCard(),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('COMMUNITY & NETWORK'),
          const SizedBox(height: AppSpacing.xs),
          _SettingsTile(
            icon: Icons.assignment_outlined,
            label: 'My Resource Requests',
            trailing: const _PendingBadge(count: 2),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            label: 'Contributor Badges',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContributorBadgesScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('SETTINGS & PREFERENCES'),
          const SizedBox(height: AppSpacing.xs),
          _SettingsTile(
            icon: Icons.school_outlined,
            label: 'Curriculum & Semester',
            trailing: Text(
              profile == null ? '' : 'Sem ${profile.currentSemester}',
              style: AppTextStyles.bodyMedium,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CurriculumScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.menu_book_outlined,
            label: 'My Subjects',
            trailing: profile != null && profile.needsSubjectsSetup
                ? const _SetupBadge()
                : const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubjectsSetupScreen(),
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.sd_storage_outlined,
            label: 'Storage & Cache',
            trailing: Text('142 MB', style: AppTextStyles.bodyMedium),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StorageCacheScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('SUPPORT & INTEGRITY'),
          const SizedBox(height: AppSpacing.xs),
          _SettingsTile(
            icon: Icons.verified_user_outlined,
            label: 'Honor Code & Guidelines',
            trailing: const Icon(
              Icons.open_in_new,
              size: 18,
              color: AppColors.textMuted,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HonorCodeScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.support_agent_outlined,
            label: 'Help Center & Issues',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.gavel_outlined,
            label: 'Privacy & Terms',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyTermsScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _LogoutButton(onTap: _confirmLogout),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Text(
                  'Semester Forge v2.4.1 (Build 2024.11)',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (profile != null)
                  Text(profile.universityName, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tap the photo to change it (opens the same sheet as Edit)
              GestureDetector(
                onTap: () => showEditProfileSheet(context),
                child: AvatarCircle(
                  name: profile.fullName,
                  size: 72,
                  imageUrl: profile.avatarUrl,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => showEditProfileSheet(context),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(profile.fullName, style: AppTextStyles.h1),
          const SizedBox(height: 2),
          Text('@${profile.username}', style: AppTextStyles.bodyMedium),
          if (profile.headline != null && profile.headline!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(profile.headline!, style: AppTextStyles.bodySemiBold),
          ],
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(profile.bio!, style: AppTextStyles.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoBadge(profile.courseShortName ?? profile.courseName),
              _InfoBadge('Semester ${profile.currentSemester}'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoBadge(profile.collegeLabel),
          const SizedBox(height: AppSpacing.lg),
          // Real counts from the API (approved uploads, own posts, likes received)
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: compactCount(profile.stats?.approvedResources ?? 0),
                  label: 'Uploads',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  value: compactCount(profile.stats?.posts ?? 0),
                  label: 'Posts',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  value: compactCount(profile.stats?.postLikes ?? 0),
                  label: 'Likes',
                  icon: Icons.favorite_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.warning),
                const SizedBox(width: 2),
              ],
              Text(
                value,
                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.overline);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.iconBox),
              ),
              child: Icon(icon, size: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTextStyles.bodySemiBold)),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SetupBadge extends StatelessWidget {
  const _SetupBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        'Setup needed',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentPink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$count Pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.accentPink,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
        label: Text(
          'Log Out of Semester Forge',
          style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.error),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}
