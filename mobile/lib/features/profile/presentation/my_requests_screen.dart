import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/segmented_tabs.dart';

enum _RequestStatus {
  pending('Pending', AppColors.accentPink),
  fulfilled('Fulfilled', AppColors.success),
  closed('Closed', AppColors.textSecondary);

  const _RequestStatus(this.label, this.color);
  final String label;
  final Color color;
}

class _Request {
  const _Request({
    required this.title,
    required this.subject,
    required this.date,
    required this.status,
    this.responses = 0,
    this.fulfilledBy,
  });

  final String title;
  final String subject;
  final String date;
  final _RequestStatus status;
  final int responses;
  final String? fulfilledBy;
}

/// My Resource Requests — what the user asked batchmates for, grouped by
/// status, with a sheet to raise a new request.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  // Shared by the tab bar and the pages, so dragging the pages moves the bar
  late final TabController _tabs = TabController(
    length: _RequestStatus.values.length,
    vsync: this,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  final List<_Request> _requests = [
    const _Request(
      title: 'DBMS Unit 4 handwritten notes (Indexing & B+ Trees)',
      subject: 'Database Management Systems',
      date: '2 days ago',
      status: _RequestStatus.pending,
      responses: 1,
    ),
    const _Request(
      title: 'Computer Networks Dec 2022 question paper',
      subject: 'Computer Networks',
      date: '5 days ago',
      status: _RequestStatus.pending,
    ),
    const _Request(
      title: 'React lab file — experiments 6 to 10',
      subject: 'Web Technology & Frameworks',
      date: '2 weeks ago',
      status: _RequestStatus.fulfilled,
      responses: 3,
      fulfilledBy: 'Aditya K.',
    ),
    const _Request(
      title: 'Software Engineering UML cheat sheet',
      subject: 'Software Engineering',
      date: '3 weeks ago',
      status: _RequestStatus.fulfilled,
      responses: 2,
      fulfilledBy: 'Neha G.',
    ),
    const _Request(
      title: 'Cloud Computing mid-sem paper 2021',
      subject: 'Cloud Computing & DevOps',
      date: '1 month ago',
      status: _RequestStatus.closed,
    ),
  ];

  static const _statuses = _RequestStatus.values;

  int _countOf(_RequestStatus status) =>
      _requests.where((r) => r.status == status).length;

  void _openNewRequestSheet() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New Resource Request', style: AppTextStyles.h1),
            const SizedBox(height: 4),
            Text(
              'Batchmates who have it can upload it for you.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'What are you looking for? *',
              hint: 'e.g. DBMS Unit 4 notes',
              controller: titleController,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Subject *',
              hint: 'e.g. Database Management Systems',
              controller: subjectController,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Submit Request',
              onPressed: () {
                final title = titleController.text.trim();
                final subject = subjectController.text.trim();
                if (title.isEmpty || subject.isEmpty) return;
                setState(() {
                  _requests.insert(
                    0,
                    _Request(
                      title: title,
                      subject: subject,
                      date: 'Just now',
                      status: _RequestStatus.pending,
                    ),
                  );
                });
                _tabs.animateTo(0); // show the new Pending request
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(_RequestStatus status) {
    final visible = _requests.where((r) => r.status == status).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Column(
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No ${status.label.toLowerCase()} requests',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        for (final request in visible) ...[
          _RequestCard(request: request),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('My Resource Requests'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedTabs(
                  controller: _tabs,
                  labels: [
                    for (final s in _statuses) '${s.label} (${_countOf(s)})',
                  ],
                  fontSize: 14,
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: _openNewRequestSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Request'),
                ),
              ],
            ),
          ),
          // Swipe the lists left / right; the tab bar follows the finger
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [for (final s in _statuses) _page(s)],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final _Request request;

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: status.color,
                  ),
                ),
              ),
              Text(request.date, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(request.title, style: AppTextStyles.h2.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            request.subject,
            style: AppTextStyles.bodySemiBold.copyWith(
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${request.responses} ${request.responses == 1 ? 'response' : 'responses'}',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (request.fulfilledBy != null)
                Text(
                  'by ${request.fulfilledBy}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
