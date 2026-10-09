import 'package:flutter/material.dart';
import '../../core/models/subject.dart';
import '../../core/theme/app_colors.dart';

/// Icon + colour for a subject. These are UI-only decorations (the backend
/// has none), so they are picked from the subject's name and code. The same
/// subject always gets the same look.
class SubjectStyle {
  const SubjectStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  static const _icons = [
    Icons.menu_book_outlined,
    Icons.storage_outlined,
    Icons.code,
    Icons.hub_outlined,
    Icons.functions,
    Icons.science_outlined,
    Icons.computer_outlined,
    Icons.lightbulb_outline,
  ];

  factory SubjectStyle.of(Subject subject) {
    // Not String.hashCode: that can differ between runs. Sum the characters.
    final seed = '${subject.code}${subject.name}'.codeUnits.fold<int>(
      0,
      (sum, c) => (sum * 31 + c) & 0x7fffffff,
    );
    return SubjectStyle(
      _icons[seed % _icons.length],
      AppColors.avatarPalette[seed % AppColors.avatarPalette.length],
    );
  }
}
