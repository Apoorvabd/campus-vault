import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/resource_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/subject_tile.dart';
import '../../subject/data/subject_data.dart';
import '../../subject/presentation/subject_detail_screen.dart';

/// Resources tab content: "Your Subjects" list followed by a "Trending"
/// section of PYQ/Notes cards. No internal scroll — this is placed
/// inside the parent HomeScreen's single CustomScrollView.
class ResourcesTab extends StatelessWidget {
  const ResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Your Subjects', trailing: 'Semester 5'),
        const SizedBox(height: AppSpacing.md),
        for (final subject in SubjectCatalog.all) ...[
          SubjectTile(
            icon: subject.icon,
            iconColor: subject.color,
            title: subject.name,
            subtitle: subject.tileSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectDetailScreen(subject: subject),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.md),
        const SectionHeader(title: 'Trending in Sem 5', trailing: 'TOP RATED'),
        const SizedBox(height: AppSpacing.md),
        ResourceCard(
          badgeLabel: 'PYQ',
          badgeVariant: StatusChipVariant.pyq,
          title: 'DBMS End-Semester Question Paper 2024 (Sol.)',
          meta: 'Delhi University · Sem 5 · PDF · 4.2 MB · ⭐ 4.8',
          uploaderName: 'Rohit M.',
          actionLabel: 'Preview',
          onAction: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        ResourceCard(
          badgeLabel: 'NOTES',
          badgeVariant: StatusChipVariant.notes,
          title: 'Complete Computer Networks Unit 3 & 4 Handwritten Notes',
          meta: 'DU CS Department · Detailed Diagrams · PDF · 18.6 MB · ⭐ 4.9',
          uploaderName: 'Ananya S.',
          actionLabel: 'Preview',
          onAction: () {},
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
