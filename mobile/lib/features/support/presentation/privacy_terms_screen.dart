import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Privacy & Terms — static Privacy Policy + Terms of Service copy.
class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Privacy & Terms'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Privacy Policy', style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.md),
          const _Section(
            title: 'What we collect',
            body:
                'Your name, college email, course, semester and college are used to personalize your feed and verify your academic standing. Documents you upload are stored either privately on your device (Save Locally) or shared to Semester Forge, depending on the option you choose at upload time.',
          ),
          const _Section(
            title: 'How we use it',
            body:
                'Academic details help match you with the right subjects and batchmates. Uploaded resources shared to Semester Forge are shown to other verified students from your course and semester.',
          ),
          const _Section(
            title: 'Sharing',
            body:
                'We never sell your personal data. Resources you save locally never leave your device unless you explicitly choose to share them to Semester Forge.',
          ),
          const _Section(
            title: 'Your controls',
            body:
                'You can delete any resource you\'ve uploaded, clear your local vault cache from Settings, and request full account deletion at any time from Account Settings.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Terms of Service', style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.md),
          const _Section(
            title: 'Academic Integrity',
            body:
                'Semester Forge is built for genuine peer-to-peer academic resource sharing. Uploading plagiarized, copyrighted, or exam-leaked material is strictly prohibited and may result in account suspension.',
          ),
          const _Section(
            title: 'Content ownership',
            body:
                'You retain ownership of resources you upload. By sharing to Semester Forge, you grant other verified students in your course a license to view and download it for personal academic use.',
          ),
          const _Section(
            title: 'Community conduct',
            body:
                'Posts and comments must follow the Honor Code — no harassment, spam, or misinformation. Repeated violations can lead to a permanent ban.',
          ),
          const _Section(
            title: 'Account termination',
            body:
                'We may suspend accounts that violate these terms. You may also delete your account at any time; your locally saved files remain on your device regardless.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Last updated: September 2026',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySemiBold.copyWith(
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
