import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/resource.dart';
import '../utils/formatters.dart';
import 'post_card.dart';
import 'resource_card.dart';
import 'saved_resource_card.dart';
import 'status_chip.dart';

/// Adapters that turn backend models into the existing card widgets, so every
/// screen renders posts and resources the same way.

StatusChipVariant chipVariantFor(ResourceType type) => switch (type) {
      ResourceType.pyq => StatusChipVariant.pyq,
      ResourceType.notes => StatusChipVariant.notes,
      ResourceType.labManual => StatusChipVariant.labManual,
      ResourceType.syllabus => StatusChipVariant.syllabus,
      ResourceType.book => StatusChipVariant.reference,
      ResourceType.assignment => StatusChipVariant.notes,
      ResourceType.other => StatusChipVariant.reference,
    };

/// "Sem 5 · PDF · 4.2 MB · 120 downloads"
String resourceMeta(Resource r) {
  final parts = <String>[
    if (r.subject?.semester != null) 'Sem ${r.subject!.semester}',
    if (r.upload != null) (r.isPdf ? 'PDF' : 'Image') else 'Link',
    r.sizeLabel,
    if (r.downloadCount > 0) '${compactCount(r.downloadCount)} views',
  ];
  return parts.join(' · ');
}

ResourceCard resourceCardFor(
  Resource r, {
  String actionLabel = 'Open',
  VoidCallback? onAction,
  VoidCallback? onBookmark,
}) =>
    ResourceCard(
      badgeLabel: r.type.label,
      badgeVariant: chipVariantFor(r.type),
      title: r.title,
      meta: resourceMeta(r),
      uploaderName: r.uploaderName,
      actionLabel: actionLabel,
      verified: r.status == ResourceStatus.approved,
      bookmarked: r.isBookmarked,
      onAction: onAction,
      onBookmark: onBookmark,
    );

SavedResourceCard savedResourceCardFor(
  Resource r, {
  VoidCallback? onAction,
  VoidCallback? onBookmark,
}) =>
    SavedResourceCard(
      badgeLabel: r.type.label,
      badgeVariant: chipVariantFor(r.type),
      title: r.title,
      subject: r.subject?.name ?? 'Subject',
      meta: r.subject?.semester != null ? 'Semester ${r.subject!.semester}' : '',
      fileInfo: resourceMeta(r),
      actionLabel: 'Open',
      actionIcon: Icons.open_in_new,
      bookmarked: r.isBookmarked,
      onAction: onAction,
      onBookmark: onBookmark,
    );

final _hashtag = RegExp(r'#(\w+)');

/// [onDelete] should only be passed for the viewer's own posts.
PostCard postCardFor(
  Post p, {
  VoidCallback? onLike,
  VoidCallback? onComment,
  VoidCallback? onBookmark,
  VoidCallback? onDelete,
  bool compact = false,
}) =>
    PostCard(
      authorName: p.author.fullName,
      authorRole: '@${p.author.username}',
      authorAvatarUrl: p.author.avatarUrl,
      timeAgo: timeAgo(p.createdAt),
      title: p.title,
      // Hashtags are shown as chips below, so drop them from the text
      body: p.content.replaceAll(_hashtag, '').replaceAll(RegExp(r'[ \t]+\n'), '\n').trim(),
      hashtags: _hashtag.allMatches(p.content).map((m) => m.group(1)!).toSet().toList(),
      coverImageUrl: p.coverImageUrl,
      likeCount: p.likeCount,
      commentCount: p.commentCount,
      bookmarkCount: p.bookmarkCount,
      liked: p.isLiked,
      bookmarked: p.isBookmarked,
      onLike: onLike,
      onComment: onComment,
      onBookmark: onBookmark,
      onDelete: onDelete,
      compact: compact,
    );
