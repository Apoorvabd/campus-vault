import 'package:flutter/material.dart';
import '../../../app_navigation.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/keep_alive_wrapper.dart';
import '../../../core/widgets/segmented_tabs.dart';
import 'create_post_screen.dart';
import 'document_flow.dart';

/// Add screen (bottom nav "+"): two swipeable tabs, "Add Document" and
/// "Create Post", styled and sliding like Community / Resources on Home.
/// Add Document is a two-step flow (see [DocumentFlowPage]); while its second
/// step shows, the tab bar is hidden and Back returns to the first step.
class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({
    super.key,
    this.initialSubject,
    this.initialTab = 0,
  });

  /// Pre-selects the subject (e.g. when opened from a Subject Detail screen).
  final Subject? initialSubject;

  /// 0 = Add Document, 1 = Create Post.
  final int initialTab;

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen>
    with SingleTickerProviderStateMixin {
  static const _navIndex = 2;

  // Shared by the tab bar and the pages: dragging the pages moves the bar
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab,
  );
  final _flowKey = GlobalKey<DocumentFlowPageState>();
  int _documentStep = 1;

  bool get _inDetailsStep => _documentStep == 2;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back on the details step goes to the file step instead of leaving
      canPop: !_inDetailsStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _flowKey.currentState?.goBack();
      },
      child: AppShellScaffold(
        currentIndex: _navIndex,
        onSearchTap: () => openSearch(context),
        onNavTap: (index) {
          if (index == _navIndex) return;
          goToTab(context, index);
        },
        body: Column(
          children: [
            if (!_inDetailsStep) ...[
              const SizedBox(height: AppSpacing.sm),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(
                  height: 1,
                  thickness: 1.2,
                  color: AppColors.border,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  0,
                ),
                child: SegmentedTabs(
                  controller: _tabs,
                  labels: const ['Add Document', 'Create Post'],
                  icons: const [
                    Icons.note_add_outlined,
                    Icons.dynamic_feed_outlined,
                  ],
                  height: 38,
                  fontSize: 16,
                ),
              ),
            ],
            Expanded(
              child: TabBarView(
                controller: _tabs,
                // No swiping away while the details step has no tab bar
                physics: _inDetailsStep
                    ? const NeverScrollableScrollPhysics()
                    : null,
                children: [
                  KeepAliveWrapper(
                    child: DocumentFlowPage(
                      key: _flowKey,
                      initialSubject: widget.initialSubject,
                      onStepChanged: (step) =>
                          setState(() => _documentStep = step),
                    ),
                  ),
                  // After posting, go to Home so the new post shows in the feed
                  KeepAliveWrapper(
                    child: PostComposerPage(
                      onPosted: () => goToTab(context, 0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
