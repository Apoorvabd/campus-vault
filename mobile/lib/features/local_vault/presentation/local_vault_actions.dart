import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/widgets/model_cards.dart';
import '../../../core/widgets/saved_resource_card.dart';
import '../bloc/local_vault_cubit.dart';
import '../data/local_vault_item.dart';

/// Opens the vault copy in the phone's PDF/image viewer.
Future<void> openLocalItem(BuildContext context, LocalVaultItem item) async {
  final messenger = ScaffoldMessenger.of(context);
  final path = await context.read<LocalVaultCubit>().pathOf(item);
  final result = await OpenFilex.open(path);
  if (result.type != ResultType.done) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No app found to open this file')),
    );
  }
}

/// Asks first, then deletes the vault copy (the original file is untouched).
Future<void> confirmDeleteLocal(
  BuildContext context,
  LocalVaultItem item,
) async {
  final cubit = context.read<LocalVaultCubit>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Remove from device?'),
      content: Text(
        '"${item.title}" will be deleted from this app (${item.sizeLabel}). '
        'The original file elsewhere on your phone is not touched.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed == true) await cubit.delete(item);
}

/// The card used for an on-device file (Saved screen + Subject Detail).
SavedResourceCard localVaultCardFor(
  BuildContext context,
  LocalVaultItem item,
) => SavedResourceCard(
  badgeLabel: item.type.label,
  badgeVariant: chipVariantFor(item.type),
  title: item.title,
  subject: item.subjectName,
  meta: item.semester != null ? 'Semester ${item.semester}' : '',
  fileInfo: item.sizeLabel,
  actionLabel: 'Open',
  actionIcon: Icons.open_in_new,
  onAction: () => openLocalItem(context, item),
  onBookmark: () => confirmDeleteLocal(context, item),
);
