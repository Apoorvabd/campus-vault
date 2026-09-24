import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_search_bar.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/avatar_circle.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../core/widgets/progress_step_header.dart';
import '../core/widgets/resource_card.dart';
import '../core/widgets/section_header.dart';
import '../core/widgets/segmented_tabs.dart';
import '../core/widgets/status_chip.dart';
import '../core/widgets/subject_tile.dart';

/// Dev-only screen that renders every core widget together so the design
/// system can be sanity-checked live in the app. Not part of the real
/// navigation flow.
class WidgetShowcaseScreen extends StatefulWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  State<WidgetShowcaseScreen> createState() => _WidgetShowcaseScreenState();
}

class _WidgetShowcaseScreenState extends State<WidgetShowcaseScreen> {
  int _tabIndex = 0;
  int _navIndex = 0;
  bool _bookmarked = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Showcase')),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _ShowcaseSection(
            title: 'AppButton',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AppButton(label: 'Sign In', icon: Icons.arrow_forward, onPressed: () {}),
                ),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Google Workspace SSO',
                    variant: AppButtonVariant.outline,
                    onPressed: () {},
                  ),
                ),
                AppButton(
                  label: 'Preview',
                  icon: Icons.remove_red_eye_outlined,
                  variant: AppButtonVariant.small,
                  expand: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          _ShowcaseSection(
            title: 'AppTextField',
            child: Column(
              children: [
                const AppTextField(
                  label: 'Roll No. or University Email',
                  hint: 'e.g., 21CS042 or student@univ.edu',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  trailingLabel: 'Forgot password?',
                  onTrailingLabelTap: () {},
                ),
              ],
            ),
          ),
          _ShowcaseSection(
            title: 'StatusChip',
            child: const Wrap(
              spacing: AppSpacing.sm,
              children: [
                StatusChip(label: 'PYQ', variant: StatusChipVariant.pyq),
                StatusChip(label: 'NOTES', variant: StatusChipVariant.notes),
                StatusChip(label: '✓ Verified', variant: StatusChipVariant.verified),
              ],
            ),
          ),
          _ShowcaseSection(
            title: 'AvatarCircle',
            child: const Row(
              children: [
                AvatarCircle(name: 'Sahil Kumar', online: true),
                SizedBox(width: AppSpacing.md),
                AvatarCircle(name: 'Priya Sharma'),
                SizedBox(width: AppSpacing.md),
                AvatarCircle(name: 'Rohit Kapoor', size: 28),
              ],
            ),
          ),
          _ShowcaseSection(
            title: 'SegmentedTabs',
            child: SegmentedTabs(
              labels: const ['Community', 'Resources'],
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
          ),
          _ShowcaseSection(
            title: 'SubjectTile',
            child: SubjectTile(
              icon: Icons.folder_rounded,
              iconColor: AppColors.primary,
              title: 'Database Management Systems',
              subtitle: '42 resources · 2024 End-Sem Verified',
              onTap: () {},
            ),
          ),
          _ShowcaseSection(
            title: 'ResourceCard',
            child: ResourceCard(
              badgeLabel: 'PYQ',
              badgeVariant: StatusChipVariant.pyq,
              title: 'DBMS End-Semester Question Paper 2024 (Sol.)',
              meta: 'Delhi University · Sem 5 · PDF · 4.2 MB · ⭐ 4.8',
              uploaderName: 'Rohit M.',
              actionLabel: 'Preview',
              bookmarked: _bookmarked,
              onBookmark: () => setState(() => _bookmarked = !_bookmarked),
              onAction: () {},
            ),
          ),
          _ShowcaseSection(
            title: 'ProgressStepHeader',
            child: const ProgressStepHeader(currentStep: 1, totalSteps: 2),
          ),
          _ShowcaseSection(
            title: 'AppSearchBar',
            child: AppSearchBar(activeFilterCount: 3, onFilterTap: () {}),
          ),
          _ShowcaseSection(
            title: 'SectionHeader',
            child: SectionHeader(title: 'Trending in Sem 5', trailing: 'TOP RATED', onTrailingTap: () {}),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ShowcaseSection extends StatelessWidget {
  const _ShowcaseSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          AppCard(child: child),
        ],
      ),
    );
  }
}
