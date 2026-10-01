import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/saved_resource_card.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../core/widgets/status_chip.dart';

class _SavedItem {
  const _SavedItem(
    this.badge,
    this.variant,
    this.title,
    this.subject,
    this.meta,
    this.fileInfo,
    this.actionLabel,
    this.actionIcon,
  );
  final String badge;
  final StatusChipVariant variant;
  final String title;
  final String subject;
  final String meta;
  final String fileInfo;
  final String actionLabel;
  final IconData actionIcon;
}

/// Saved Vault screen — locally saved / downloaded PDFs / bookmarked posts,
/// with subject filters and offline-storage usage summary.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  static const _navIndex = 3;
  int _tabIndex = 0;
  int _filterIndex = 0;

  static const _subjectFilters = [
    'All Subjects',
    'DBMS (5)',
    'Networks (4)',
    'Python (3)',
  ];

  static const _items = [
    _SavedItem(
      'PYQ',
      StatusChipVariant.pyq,
      'DBMS Regular Examination Question Paper (Dec 2024)',
      'Database Management Systems',
      'B.Voc Software Dev (Sem 5)',
      '12 Pages · 2.4 MB PDF',
      'Open Reader',
      Icons.remove_red_eye_outlined,
    ),
    _SavedItem(
      'NOTES',
      StatusChipVariant.notes,
      'Complete Computer Networks Unit 3 & 4 Handwritten Notes',
      'Computer Networks',
      'B.Voc Software Dev (Sem 5)',
      '38 Pages · 18.6 MB PDF',
      'View Offline',
      Icons.description_outlined,
    ),
    _SavedItem(
      'LAB MANUAL',
      StatusChipVariant.labManual,
      'Web Technology React & Node Practical File Solutions',
      'Web Technology & Frameworks',
      'B.Voc Software Dev (Sem 5)',
      '24 Pages · 5.1 MB PDF',
      'View Offline',
      Icons.menu_book_outlined,
    ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Saved Vault',
                  style: AppTextStyles.displayBold.copyWith(fontSize: 29),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  shape: BoxShape.rectangle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.tune,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.cloud_done_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Offline Access Enabled · 348 MB used',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.09),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _StatColumn(label: 'Locally Saved', value: '14 items'),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Downloaded',
                    value: '8 PDFs',
                    valueColor: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _StatColumn(label: 'Bookmarked', value: '19 Posts'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SegmentedTabs(
            labels: const ['Locally Saved', 'Downloaded (PDF)', 'Bookmarks'],
            selectedIndex: _tabIndex,
            onChanged: (index) => setState(() => _tabIndex = index),
            fontSize: 12,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _subjectFilters.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final selected = index == _filterIndex;
                return GestureDetector(
                  onTap: () => setState(() => _filterIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      _subjectFilters[index],
                      style: AppTextStyles.bodySemiBold.copyWith(
                        fontSize: 13,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final item in _items) ...[
            SavedResourceCard(
              badgeLabel: item.badge,
              badgeVariant: item.variant,
              title: item.title,
              subject: item.subject,
              meta: item.meta,
              fileInfo: item.fileInfo,
              actionLabel: item.actionLabel,
              actionIcon: item.actionIcon,
              starred: item == _items.first,
              onStar: () {},
              onBookmark: () {},
              onAction: () {},
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const _StorageUsageCard(),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StorageUsageCard extends StatelessWidget {
  const _StorageUsageCard();

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
                  const Icon(
                    Icons.sd_storage_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Vault Storage Used', style: AppTextStyles.bodySemiBold),
                ],
              ),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.primary,
                  ),
                  children: const [
                    TextSpan(text: '348 MB'),
                    TextSpan(
                      text: ' / 2.0 GB',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: 348 / 2048,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1.65 GB Free offline headroom',
                style: AppTextStyles.caption,
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Manage & Clear Cache ›',
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
