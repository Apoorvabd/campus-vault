import 'package:flutter/material.dart';
import '../../../app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import 'create_post_screen.dart';

enum _SaveDestination { local, vault }

/// "Create Document" screen — opened from the bottom nav's Add tab.
/// Matches the Stitch "Create Document" design: academic classification
/// form, attached-file preview, and a save-destination picker.
class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({super.key});

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  static const _navIndex = 2;
  int _categoryIndex = 0;
  _SaveDestination _destination = _SaveDestination.vault;
  bool _offlineCopy = true;

  static const _categories = [
    'PYQ',
    'Notes',
    'Lab Manual',
    'Syllabus',
    'Reference Book',
  ];

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
          // Text('Create Document', style: AppTextStyles.h1),
          // const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ModeToggle(
                  label: 'Add Document',
                  icon: Icons.note_add_outlined,
                  selected: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ModeToggle(
                  label: 'Create Post',
                  icon: Icons.dynamic_feed_outlined,
                  selected: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            icon: Icons.assignment_outlined,
            title: 'Academic Classification & Details',
            children: [
              const AppTextField(
                label: 'Document Name / Title *',
                hint: 'DBMS End-Sem Solved Papers & Unit 3 Notes',
              ),
              const SizedBox(height: AppSpacing.lg),
              const _DropdownField(
                label: 'Course / Degree *',
                value: 'B.Voc Software Development',
              ),
              const SizedBox(height: AppSpacing.lg),
              const _DropdownField(
                label: 'Semester *',
                value: 'Semester 5 (Current)',
              ),
              const SizedBox(height: AppSpacing.lg),
              const _DropdownField(
                label: 'Subject Name / Code *',
                value: 'Database Management Systems (CS501)',
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Resource Category *',
                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(_categories.length, (index) {
                  final selected = index == _categoryIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _categoryIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _categories[index],
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontSize: 13,
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _DropdownField(
                label: 'Year / Exam Session',
                value: '2024 - Dec Regular',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            icon: Icons.attach_file,
            title: 'Attached File',
            titleTrailing: GestureDetector(
              onTap: () {},
              child: Text(
                'Change File',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.iconBox),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DBMS_Unit_3_Transactions_Co...',
                            style: AppTextStyles.bodySemiBold.copyWith(
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text('3.4 MB · ', style: AppTextStyles.caption),
                              Text(
                                'Ready to upload',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Supported: PDF, DOCX, ZIP, EPUB',
                    style: AppTextStyles.caption,
                  ),
                  Text('Max size: 45 MB', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            icon: Icons.shield_outlined,
            title: 'Where do you want to save this?',
            children: [
              _DestinationOption(
                title: 'Save Locally',
                subtitle: 'Offline private vault on phone storage only.',
                footerIcon: Icons.lock_outline,
                footerLabel: 'Private to you',
                selected: _destination == _SaveDestination.local,
                onTap: () =>
                    setState(() => _destination = _SaveDestination.local),
              ),
              const SizedBox(height: AppSpacing.md),
              _DestinationOption(
                title: 'Campus Vault',
                badge: '+50 XP',
                subtitle: 'Community accessible, verified by batchmates.',
                selected: _destination == _SaveDestination.vault,
                onTap: () =>
                    setState(() => _destination = _SaveDestination.vault),
                trailing: _destination == _SaveDestination.vault
                    ? Row(
                        children: [
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text('Offline copy', style: AppTextStyles.caption),
                          const SizedBox(width: AppSpacing.sm),
                          Checkbox(
                            value: _offlineCopy,
                            onChanged: (value) =>
                                setState(() => _offlineCopy = value ?? true),
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Upload & Save Document',
            icon: Icons.arrow_forward,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Files adhere to Campus Academic Integrity standards · 256-bit safe transmission',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontSize: 14,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.titleTrailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15)),
                ],
              ),
              ?titleTrailing,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: AppColors.textPrimary.withValues(alpha: 0.5),
              width: 1.9,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestinationOption extends StatelessWidget {
  const _DestinationOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
    this.footerIcon,
    this.footerLabel,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final IconData? footerIcon;
  final String? footerLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryLight.withValues(alpha: 0.4)
              : AppColors.background,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15),
                ),
                if (badge != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(subtitle, style: AppTextStyles.caption),
            ),
            if (footerIcon != null && footerLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Row(
                  children: [
                    Icon(footerIcon, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      footerLabel!,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
