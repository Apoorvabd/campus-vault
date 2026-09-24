import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import 'signup_step_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/presentation/homescreen.dart';

class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({super.key});

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  int _selectedSemester = 4;
  bool _agreedToTerms = true;

  @override
  Widget build(BuildContext context) {
    return SignupStepScaffold(
      currentStep: 2,
      totalSteps: 2,
      title: 'Academic Details',
      subtitle: 'Step 2 of 2: Connect your campus curriculum',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTextField(
              label: 'University',
              hint: 'Delhi University (DU)',
              suffixIcon: Icons.check_circle,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'College / Institute',
              hint: 'Search your college',
              suffixIcon: Icons.search,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Course / Degree',
              hint: 'e.g. B.Tech Computer Science',
              suffixIcon: Icons.keyboard_arrow_down,
            ),
            // yahan aage semester grid add karenge
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Semester', style: AppTextStyles.bodySemiBold.copyWith(fontSize: 17)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(8, (index) {
                final semester = index + 1;
                final selected = semester == _selectedSemester;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSemester = semester),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                    child: Text(
                      'Sem $semester',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        fontSize: 14,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  activeColor: AppColors.primary,
                  onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium,
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service & Campus Academic Honor Code',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600,fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),            
              ],
            ),
          ),
         const SizedBox(height: AppSpacing.md),
         AppButton(
            label: 'Complete Setup',
            icon: Icons.arrow_forward,
            fontSize: 22,
            radius: 0,                                                                                    // ← corner rounding hata di
            verticalPadding: 17,                        // ← height badhi (pehle theme default 14 tha)
            onPressed: () {
                        Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    (route) => false,
                        );
            },
),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('Back to Step 1', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}