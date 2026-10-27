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
                'Your name, email, course, semester and college are used to personalize your feed and verify your academic standing. If you sign up or log in with Google, Google gives us your name, email address and Google account ID, and nothing else: we never see your Google password, and we do not access your Gmail, Drive, contacts or any other Google data. When you sign up with email, we send a one-time code to that address to confirm it. Documents you upload are stored either privately on your device (Save Locally) or shared to Semester Forge, depending on the option you choose at upload time.',
          ),
          const _Section(
            title: 'How we use it',
            body:
                'Academic details help match you with the right subjects and batchmates. Your name and email are used to create your account, log you in, and send you verification codes and important account notices. Uploaded resources shared to Semester Forge are shown to other verified students from your course and semester.',
          ),
          const _Section(
            title: 'Sharing',
            body:
                'We never sell your personal data, and information from your Google account is never shared with advertisers or used for advertising. We use service providers to run the app (hosting and database, file storage, and email delivery); they handle data only on our behalf. Resources you save locally never leave your device unless you explicitly choose to share them to Semester Forge. Semester Forge\'s use of information received from Google follows the Google API Services User Data Policy, including its Limited Use requirements.',
          ),
          const _Section(
            title: 'Your controls',
            body:
                'You can delete any resource you\'ve uploaded, clear your local vault cache from Settings, and request full account deletion at any time from Account Settings. If you signed in with Google, you can also remove Semester Forge\'s access from your Google Account settings at myaccount.google.com/permissions.',
          ),
          const _Section(
            title: 'Contact',
            body: 'Questions about your data? Email support@semesterforge.in.',
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
              'Last updated: October 2026',
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
