import 'package:flutter/material.dart';
import '../../../app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/resource_card.dart';
import '../../upload/presentation/create_document_screen.dart';
import '../data/subject_data.dart';

/// Subject Detail — opened by tapping a subject on the Resources tab.
/// Shows only the user's own items for that subject: downloaded PDFs,
/// bookmarks and locally saved files.
class SubjectDetailScreen extends StatefulWidget {
  const SubjectDetailScreen({super.key, required this.subject});

  final SubjectInfo subject;

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  ResourceSource? _filter;

  SubjectInfo get _s => widget.subject;

  @override
  Widget build(BuildContext context) {
    final visible = _filter == null
        ? _s.resources
        : _s.resources.where((r) => r.source == _filter).toList();

    return AppShellScaffold(
      currentIndex: 0,
      showBackButton: true,
      onSearchTap: () => openSearch(context),
      onNavTap: (index) {
        if (index == 0) {
          Navigator.maybePop(context);
          return;
        }
        goToTab(context, index);
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateDocumentScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Upload to ${_s.shortName}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ResourceSource.values.length + 1,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final source = index == 0
                    ? null
                    : ResourceSource.values[index - 1];
                final selected = source == _filter;
                final label = source == null
                    ? 'All (${_s.resources.length})'
                    : '${source.label} (${_s.countOf(source)})';
                return GestureDetector(
                  onTap: () => setState(() => _filter = source),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
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
                      label,
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
          Text(
            '${visible.length} ${visible.length == 1 ? 'item' : 'items'}',
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final resource in visible) ...[
            ResourceCard(
              badgeLabel: resource.category.badge,
              badgeVariant: resource.category.variant,
              title: resource.title,
              meta: resource.meta,
              uploaderName: resource.uploader,
              verified: resource.verified,
              bookmarked: resource.source == ResourceSource.bookmarked,
              actionLabel: switch (resource.source) {
                ResourceSource.downloaded => 'Open Reader',
                ResourceSource.local => 'View Offline',
                ResourceSource.bookmarked => 'View PDF',
              },
              onBookmark: () {},
              onAction: () {},
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _s.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.iconBox),
                ),
                child: Icon(_s.icon, color: _s.color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(_s.name, style: AppTextStyles.h1)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _s.code,
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text('•', style: AppTextStyles.caption),
              _MiniChip(label: _s.type, color: _s.color),
              _MiniChip(
                label: 'Semester ${_s.semester}',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(_s.course, style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${_s.countOf(ResourceSource.local)}',
                  label: 'Locally Saved',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  value: '${_s.countOf(ResourceSource.downloaded)}',
                  label: 'Downloaded',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatBox(
                  value: '${_s.countOf(ResourceSource.bookmarked)}',
                  label: 'Bookmarked',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
