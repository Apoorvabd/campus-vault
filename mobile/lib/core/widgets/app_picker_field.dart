import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppPickerField<T> extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.itemSubtitle,
    this.moreLabel,
    this.onMore,
    this.value,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final List<T> items;
  final String Function(T item) itemLabel; // how to show one item as text
  final ValueChanged<T> onSelected; // called when the user picks something
  final String? Function(T item)? itemSubtitle; // optional second line, also searchable

  /// Optional row pinned at the bottom of the sheet (e.g. "More subjects").
  /// [onMore] opens something that can return an item; if it does, the sheet
  /// closes with that item as the answer.
  final String? moreLabel;
  final Future<T?> Function(BuildContext context)? onMore;
  final T? value; // currently selected item, if any
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15)),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.input),
          onTap: enabled && !isLoading ? () => _openSheet(context) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              enabled: enabled,
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(9),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textMuted,
                    ),
            ),
            child: Text(
              hasValue ? itemLabel(value as T) : hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontWeight: FontWeight.w400,
                color: hasValue ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    // The sheet returns the picked item when it closes (null if dismissed)
    final picked = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (_) => _PickerSheet<T>(
        title: label,
        items: items,
        itemLabel: itemLabel,
        itemSubtitle: itemSubtitle,
        moreLabel: moreLabel,
        onMore: onMore,
        selected: value,
      ),
    );
    if (picked != null) onSelected(picked);
  }
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.itemSubtitle,
    required this.moreLabel,
    required this.onMore,
    required this.selected,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final String? moreLabel;
  final Future<T?> Function(BuildContext context)? onMore;
  final T? selected;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final filtered = widget.items
        .where((item) {
          final subtitle = widget.itemSubtitle?.call(item) ?? '';
          return '${widget.itemLabel(item)} $subtitle'.toLowerCase().contains(q);
        })
        .toList();
    final showSearch = widget.items.length > 8; // short lists need no search
    final media = MediaQuery.of(context);

    return Padding(
      // lift the sheet above the keyboard
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(widget.title, style: AppTextStyles.h2),
            ),
            if (showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Text(
                          widget.items.isEmpty
                              ? 'Nothing to choose from yet'
                              : 'No results',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isSelected = item == widget.selected;
                        final subtitle = widget.itemSubtitle?.call(item);
                        return ListTile(
                          subtitle: subtitle == null || subtitle.isEmpty
                              ? null
                              : Text(subtitle, style: AppTextStyles.caption),
                          title: Text(
                            widget.itemLabel(item),
                            style: AppTextStyles.bodySemiBold.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                )
                              : null,
                          // closes the sheet and hands the item back
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
            if (widget.onMore != null && widget.moreLabel != null) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.search, color: AppColors.primary),
                title: Text(
                  widget.moreLabel!,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final picked = await widget.onMore!(context);
                  if (picked != null) navigator.pop(picked);
                },
              ),
              SizedBox(height: media.padding.bottom),
            ],
          ],
        ),
      ),
    );
  }
}
