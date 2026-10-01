import 'package:flutter/material.dart';
import '../../../app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../support/presentation/help_center_screen.dart';
import '../../support/presentation/privacy_terms_screen.dart';

/// Account Settings screen — opened from the bottom nav's Profile tab.
/// Matches the Stitch "Account Settings" design.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _navIndex = 4;
  bool _showAppBanner = true;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const AvatarCircle(name: 'Aryan Sharma', size: 32),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_showAppBanner) ...[
            _AppInfoBanner(
              onClose: () => setState(() => _showAppBanner = false),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          const _ProfileCard(),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('COMMUNITY & NETWORK'),
          const SizedBox(height: AppSpacing.sm),
          _SettingsTile(
            icon: Icons.assignment_outlined,
            label: 'My Resource Requests',
            trailing: const _PendingBadge(count: 2),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            label: 'Contributor Badges',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('SETTINGS & PREFERENCES'),
          const SizedBox(height: AppSpacing.sm),
          _SettingsTile(
            icon: Icons.school_outlined,
            label: 'Curriculum & Semester',
            trailing: Text('Sem 5', style: AppTextStyles.bodyMedium),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.sd_storage_outlined,
            label: 'Storage & Cache',
            trailing: Text('142 MB', style: AppTextStyles.bodyMedium),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('SUPPORT & INTEGRITY'),
          const SizedBox(height: AppSpacing.sm),
          _SettingsTile(
            icon: Icons.verified_user_outlined,
            label: 'Honor Code & Guidelines',
            trailing: const Icon(
              Icons.open_in_new,
              size: 18,
              color: AppColors.textMuted,
            ),
            onTap: () {},
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
          const SizedBox(height: AppSpacing.xl),
          _LogoutButton(onTap: () {}),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  'Campus Vault v2.4.1 (Build 2024.11)',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Delhi University Central Academic Archive',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppInfoBanner extends StatelessWidget {
  const _AppInfoBanner({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.iconBox),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campus Vault', style: AppTextStyles.bodySemiBold),
                Text('v2.4 · DU North Campus', style: AppTextStyles.caption),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

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
              const AvatarCircle(name: 'Aryan Sharma', size: 72, online: true),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
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
          Text('Aryan Sharma', style: AppTextStyles.h1),
          const SizedBox(height: 2),
          Text('@aryansharma_du', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              _InfoBadge('B.Voc Software Dev'),
              _InfoBadge('Semester 5'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const _InfoBadge('Ramanujan College (DU)'),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: const [
              Expanded(
                child: _StatBox(value: '42', label: 'Uploads'),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(value: '1.2k', label: 'Downloads'),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  value: '4.9',
                  label: 'Rating',
                  icon: Icons.star_rounded,
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
          'Log Out of Campus Vault',
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
