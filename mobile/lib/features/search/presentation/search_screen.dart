import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/resource_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/home_top_bar.dart';

class _SearchResult {
  const _SearchResult(
    this.badge,
    this.variant,
    this.title,
    this.meta,
    this.uploader,
  );
  final String badge;
  final StatusChipVariant variant;
  final String title;
  final String meta;
  final String uploader;
}

/// Search screen: blank (filters + recent searches) until the user
/// submits a query, then shows the results list — matches the
/// "DBMS 2024 PYQ" search-results design.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _hasSearched = false;

  static const _recentSearches = [
    'Software Engineering Unit 3',
    'Discrete Maths 2023',
    'Web Dev Lab Manual',
  ];

  static const _results = [
    _SearchResult(
      'PYQ',
      StatusChipVariant.pyq,
      'DBMS Regular Examination Question Paper (Dec 2024)',
      'Database Management Systems · B.Voc Software Dev · Sem 5 · 12 pgs · 2.4 MB · ⭐ 4.9 (89)',
      'Priya Sharma',
    ),
    _SearchResult(
      'PYQ',
      StatusChipVariant.pyq,
      'DBMS Internal Assessment Model Paper 2024 with Solutions',
      'Database Management Systems · Department Vault Official · Sem 5 · 6 pgs · 1.1 MB · ⭐ 4.8 (42)',
      'Academic Archive Team',
    ),
    _SearchResult(
      'NOTES',
      StatusChipVariant.notes,
      'DBMS Mid-Term Solved Question Bank (2024 Revised Syllabus)',
      'Relational Algebra, SQL Triggers & Normalization · Sem 5 · 18 pgs · 3.8 MB · ⭐ 5.0 (115)',
      'CS Toppers Circle',
    ),
  ];

  void _runSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() => _hasSearched = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeTopBar(
        showBackButton: true,
        searchController: _controller,
        readOnly: false,
        autofocus: true,
        onSubmitted: _runSearch,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _FilterDropdownChip(label: 'PYQ'),
                  SizedBox(width: AppSpacing.sm),
                  _FilterDropdownChip(label: 'Sem: 5'),
                  SizedBox(width: AppSpacing.sm),
                  _FilterDropdownChip(label: 'Year: 2024'),
                  SizedBox(width: AppSpacing.sm),
                  _FilterDropdownChip(label: 'Subject'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _hasSearched ? _buildResults() : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Results', style: AppTextStyles.h1),
                Text(
                  '${_results.length} papers found',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.swap_vert,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Most Downloaded',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final result in _results) ...[
          ResourceCard(
            badgeLabel: result.badge,
            badgeVariant: result.variant,
            title: result.title,
            meta: result.meta,
            uploaderName: result.uploader,
            actionLabel: 'View PDF',
            onAction: () {},
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: AppTextStyles.h2),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Clear',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _recentSearches
              .map(
                (term) => GestureDetector(
                  onTap: () {
                    _controller.text = term;
                    _runSearch(term);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(term, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _FilterDropdownChip extends StatelessWidget {
  const _FilterDropdownChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
