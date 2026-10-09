import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/profile_card.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/keep_alive_wrapper.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../upload/presentation/create_document_screen.dart';
import 'community_tab.dart';
import 'resources_tab.dart';
import '../../../core/widgets/skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _navIndex = 0;
  // Hidden for now; the bottom nav's + button also opens Add Document
  static const _showUploadButton = false;

  // Shared by the tab bar and the pages: dragging the pages moves the bar
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      currentIndex: _navIndex,
      onSearchTap: () => openSearch(context),
      onNavTap: (index) {
        if (index == _navIndex) return;
        goToTab(context, index);
      },
      floatingActionButton: _showUploadButton && _tabs.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateDocumentScreen()),
              ),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Upload Notes',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      // The profile card scrolls away with either page's list; the tab bar
      // then sits at the top of the body, above the swipeable pages.
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              // Real user from the app-wide ProfileCubit
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final profile = state.profile;
                  if (profile != null) {
                    return ProfileHeaderCard(
                      name: profile.fullName,
                      role: profile.roleLabel,
                      username: profile.username,
                      avatarUrl: profile.avatarUrl,
                      degree: profile.courseName,
                      semester: profile.currentSemester,
                      college: profile.collegeLabel,
                    );
                  }
                  return AppCard(
                    child: state.error != null
                        ? ErrorView(
                            message: state.error!,
                            onRetry: () => context.read<ProfileCubit>().load(),
                          )
                        : const SkeletonProfileCard(),
                  );
                },
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Thin line that sits right on top of the tabs
            // Same side margins as the tab bar, so it is exactly as wide as the
            // line under Community / Resources
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Divider(
                height: 1,
                thickness: 1.2,
                color: AppColors.border,
              ),
            ),
            ColoredBox(
              color: AppColors.background,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  0,
                ),
                child: SegmentedTabs(
                  controller: _tabs,
                  height: 38, // short, so the labels stay close to the line
                  labels: const ['Community', 'Resources'],
                  icons: const [Icons.people_outline, Icons.menu_book_outlined],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  KeepAliveWrapper(child: CommunityTab()),
                  KeepAliveWrapper(child: ResourcesTab()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
