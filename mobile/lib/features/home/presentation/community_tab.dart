import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/post_card.dart';

/// Community feed: filter row (All Posts / Resource Requests / Create Post)
/// followed by a scrollable list of posts.
class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _FilterChip(
              label: 'All Posts',
              selected: _filterIndex == 0,
              onTap: () => setState(() => _filterIndex = 0),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Resource Requests',
              selected: _filterIndex == 1,
              onTap: () => setState(() => _filterIndex = 1),
            ),
            const Spacer(),
            // AppButton(
            //   label: 'Create Post',
            //   icon: Icons.edit_outlined,
            //   variant: AppButtonVariant.small,
            //   expand: false,
            //   onPressed: () {},
            // ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const PostCard(
          authorName: 'Sahil Kumar',
          authorRole: '2nd Year',
          timeAgo: '2h',
          online: true,
          title: 'Looking for 2023 DBMS Mid-Sem Solved Papers (Unit 2) 🚨',
          body:
              'Hey peeps! Need question papers and step-by-step SQL '
              'normalization (3NF/BCNF) query solutions before tomorrow\'s '
              'lab test. If anyone has handwritten classroom notes or '
              'Prof. Verma\'s solved question bank, please share below!',
          hashtags: ['DBMS', 'MidSemPrep', 'Semester5', 'RamanujanCollege'],
          attachment: PostAttachment(
            title: 'DBMS_Unit2_PYQ_Reference.pdf',
            subtitle: 'Question Paper Template · 4 pages',
          ),
          likeCount: 34,
          commentCount: 14,
          bookmarkCount: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        const PostCard(
          authorName: 'Priya Sharma',
          authorRole: '1st Year',
          timeAgo: '4h',
          title:
              'Important topics list for Web Tech React internal viva by Prof. Sharma 💡',
          body:
              'I compiled the recurring viva questions asked during '
              'the morning batch lab evaluations! Focus primarily on: '
              'Custom Hooks vs Higher Order Components (HOC), Virtual '
              'DOM reconciliation & Fiber tree algorithm, Redux Toolkit '
              'slices vs standard Context API',
          hashtags: ['WebDev', 'ReactJS', 'VivaPreparation', 'Sem5DU'],
          likeCount: 58,
          commentCount: 19,
          bookmarkCount: 8,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
