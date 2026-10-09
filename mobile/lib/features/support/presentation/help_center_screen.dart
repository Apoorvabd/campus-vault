import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
}

/// Help Center & Issues — contact/report actions plus a static FAQ list.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    _Faq(
      'How do I upload a resource?',
      'Tap the Add tab on the bottom nav, fill in the course, semester and subject, attach your file and choose whether to save it to Semester Forge or keep it locally.',
    ),
    _Faq(
      'Why was my document rejected?',
      'Batchmates or moderators can flag a document for being mislabeled, low quality, or violating the Honor Code. You will see the reason on the document\'s status once reviewed.',
    ),
    _Faq(
      'How does offline storage work?',
      'When you save a document with an offline copy, Semester Forge keeps a private copy on your device so you can open it without internet — it never leaves your phone unless you also share it to the Vault.',
    ),
    _Faq(
      'How do I earn XP?',
      'You earn XP by uploading resources to Semester Forge, getting upvotes from batchmates, and maintaining a good contributor rating.',
    ),
    _Faq(
      'How do I report inappropriate content?',
      'Open the post or resource, tap the overflow menu, and choose Report. Our moderation team reviews every report within 48 hours.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Help Center & Issues'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(
                child: _ContactAction(
                  icon: Icons.chat_bubble_outline,
                  label: 'Contact Support',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ContactAction(
                  icon: Icons.bug_report_outlined,
                  label: 'Report an Issue',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Frequently Asked Questions', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          for (final faq in _faqs) ...[
            _FaqTile(faq: faq),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Text('Still need help?', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 4),
                Text(
                  'Email us at support@semesterforge.app',
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

class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(faq.answer, style: AppTextStyles.bodyMedium)],
        ),
      ),
    );
  }
}
