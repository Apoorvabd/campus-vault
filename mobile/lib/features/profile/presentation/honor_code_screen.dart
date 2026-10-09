import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class _Principle {
  const _Principle(this.icon, this.color, this.title, this.body);
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

/// Honor Code & Guidelines — community principles, consequences, and a
/// pledge the user can acknowledge.
class HonorCodeScreen extends StatefulWidget {
  const HonorCodeScreen({super.key});

  @override
  State<HonorCodeScreen> createState() => _HonorCodeScreenState();
}

class _HonorCodeScreenState extends State<HonorCodeScreen> {
  bool _agreed = false;

  static const _principles = [
    _Principle(
      Icons.edit_note_rounded,
      AppColors.primary,
      'Share original work',
      'Upload notes, papers and files you created or have the right to share. Credit the source when you build on someone else\'s material.',
    ),
    _Principle(
      Icons.copyright_rounded,
      AppColors.accentPurple,
      'Respect copyright',
      'Do not upload full textbooks or paid course material. Short summaries and your own annotations are welcome.',
    ),
    _Principle(
      Icons.gpp_bad_outlined,
      AppColors.error,
      'No exam leaks',
      'Never share live exam papers, answer keys or proxy attendance material. Only previous year papers released after the exam.',
    ),
    _Principle(
      Icons.handshake_outlined,
      AppColors.success,
      'Be respectful',
      'Keep posts and comments kind and on topic. Harassment, spam and personal attacks are not tolerated.',
    ),
    _Principle(
      Icons.fact_check_outlined,
      AppColors.accentTeal,
      'Label honestly',
      'Pick the right course, semester, subject and category so batchmates can trust what they download.',
    ),
    _Principle(
      Icons.flag_outlined,
      AppColors.accentOrange,
      'Report violations',
      'See something wrong? Use Report on any post or resource. Moderators review every report within 48 hours.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Honor Code & Guidelines'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus Academic Honor Code',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Semester Forge runs on trust between batchmates. These six principles keep the archive useful and fair for everyone.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('PRINCIPLES', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          for (final p in _principles) ...[
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.iconBox),
                    ),
                    child: Icon(p.icon, color: p.color, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title, style: AppTextStyles.bodySemiBold),
                        const SizedBox(height: 4),
                        Text(p.body, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('IF THE CODE IS BROKEN', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: const [
                _Step(
                  number: '1',
                  title: 'Warning',
                  body: 'The content is removed and you are told why.',
                ),
                SizedBox(height: AppSpacing.md),
                _Step(
                  number: '2',
                  title: 'Temporary suspension',
                  body:
                      'Repeat issues pause your uploads and posting for 14 days.',
                ),
                SizedBox(height: AppSpacing.md),
                _Step(
                  number: '3',
                  title: 'Permanent ban',
                  body: 'Serious or continued violations end your access.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.input),
            onTap: () => setState(() => _agreed = !_agreed),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _agreed
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.surface,
                border: Border.all(
                  color: _agreed ? AppColors.success : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Row(
                children: [
                  Icon(
                    _agreed ? Icons.check_circle : Icons.circle_outlined,
                    color: _agreed ? AppColors.success : AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _agreed
                          ? 'You have agreed to the Honor Code'
                          : 'I have read and agree to follow the Honor Code',
                      style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
              ),
              Text(
                body,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
