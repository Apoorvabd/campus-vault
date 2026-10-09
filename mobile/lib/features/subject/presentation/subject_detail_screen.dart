import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_navigation.dart';
import '../../../core/data/bookmarks_repository.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/models/resource.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/model_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../local_vault/bloc/local_vault_cubit.dart';
import '../../local_vault/bloc/local_vault_state.dart';
import '../../local_vault/data/local_vault_item.dart';
import '../../local_vault/presentation/local_vault_actions.dart';
import '../../resources/bloc/resource_list_cubit.dart';
import '../../resources/bloc/resource_list_state.dart';
import '../../resources/resource_actions.dart';
import '../../upload/presentation/create_document_screen.dart';
import '../subject_style.dart';
import '../../../core/widgets/skeleton.dart';

/// Subject Detail — opened by tapping a subject on the Resources tab.
/// Shows every resource listed for that subject plus the files the user saved
/// on this device for it. Filterable by type.
class SubjectDetailScreen extends StatefulWidget {
  const SubjectDetailScreen({super.key, required this.subject});

  final Subject subject;

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  late final ResourceListCubit _cubit;
  final _scroll = ScrollController();
  ResourceType? _filter; // null = All

  Subject get _s => widget.subject;

  @override
  void initState() {
    super.initState();
    _cubit = ResourceListCubit(
      context.read<ResourcesRepository>(),
      context.read<BookmarksRepository>(),
    );
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        _cubit.loadMore();
      }
    });
    _load();
  }

  void _load() => _cubit.load(ResourceQuery(subjectId: _s.id, type: _filter));

  void _setFilter(ResourceType? type) {
    if (type == _filter) return;
    setState(() => _filter = type);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ResourceListCubit, ResourceListState>(
        listener: (context, state) {
          if (state.actionError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionError!)));
          }
        },
        builder: (context, state) => _buildScaffold(context, state),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ResourceListState state) {
    return AppShellScaffold(
      currentIndex: 0,
      showBackButton: true,
      onSearchTap: () => openSearch(context),
      onNavTap: (index) {
        if (index == 0) {
          Navigator.maybePop(context);
          return;
        }
        goToTab(context, index);
      },
      body: RefreshIndicator(
        onRefresh: _cubit.refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildHeaderCard(state),
            const SizedBox(height: AppSpacing.lg),
            _buildFilterChips(),
            const SizedBox(height: AppSpacing.lg),
            _buildResourcesHeader(state),
            const SizedBox(height: AppSpacing.md),
            ..._buildList(context, state),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// "Resources (3)" on the left, the dashed "Add resource" button on the right.
  Widget _buildResourcesHeader(ResourceListState state) {
    final loaded = state.hasLoaded && state.error == null;
    return Row(
      children: [
        Expanded(
          child: Text(
            loaded ? 'Resources (${state.total})' : 'Resources',
            style: AppTextStyles.bodySemiBold.copyWith(fontSize: 16),
          ),
        ),
        _AddResourceButton(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDocumentScreen(initialSubject: _s),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final types = <ResourceType?>[null, ...ResourceType.values];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final type = types[index];
          final selected = type == _filter;
          return GestureDetector(
            onTap: () => _setFilter(type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                border: selected ? null : Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                type?.label ?? 'All',
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Files saved on this device for this subject (and the chosen type).
  List<LocalVaultItem> _localItems(LocalVaultState vault) => [
    for (final i in vault.items)
      if (i.subjectId == _s.id && (_filter == null || i.type == _filter)) i,
  ];

  List<Widget> _buildList(BuildContext context, ResourceListState state) {
    if (state.isLoading || !state.hasLoaded)
      return [const SkeletonResourceList()];
    if (state.error != null) {
      return [ErrorView(message: state.error!, onRetry: _load)];
    }
    final local = _localItems(context.watch<LocalVaultCubit>().state);
    if (state.items.isEmpty && local.isEmpty) {
      return [
        EmptyView(
          title: 'No resources yet',
          message: _filter == null
              ? 'Nothing has been added for this subject yet. Be the first to add one.'
              : 'No ${_filter!.label} for this subject yet.',
          icon: Icons.folder_open_outlined,
        ),
      ];
    }
    final repository = context.read<ResourcesRepository>();
    return [
      if (local.isNotEmpty) ...[
        Text(
          'On this device (${local.length})',
          style: AppTextStyles.bodySemiBold,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final item in local) ...[
          localVaultCardFor(context, item),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
      if (state.items.isNotEmpty) ...[
        for (final resource in state.items) ...[
          resourceCardFor(
            resource,
            onAction: () => openResource(context, repository, resource),
            onBookmark: () => _cubit.toggleBookmark(resource),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state.isLoadingMore) const SkeletonResourceList(count: 1),
      ],
    ];
  }

  Widget _buildHeaderCard(ResourceListState state) {
    final style = SubjectStyle.of(_s);
    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.iconBox),
                ),
                child: Icon(style.icon, color: style.color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(_s.name, style: AppTextStyles.h1)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Code on the left, type + semester badges pushed to the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _s.code,
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _MiniChip(label: _s.type, color: style.color),
                    _MiniChip(
                      label: _s.semester == null
                          ? 'All semesters'
                          : 'Semester ${_s.semester}',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// Outlined button with a dashed accent border: "+ Add resource".
class _AddResourceButton extends StatelessWidget {
  const _AddResourceButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.primary,
          radius: AppRadius.input,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Add resource',
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9; // 5 drawn, 4 gap
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
