import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/subject.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_picker_field.dart';
import '../../../core/widgets/skeleton.dart';

/// Subject dropdown of the user's own subjects. Its sheet ends with a
/// "More subjects" row that opens a search over every other subject.
class SubjectPickerField extends StatelessWidget {
  const SubjectPickerField({
    super.key,
    required this.label,
    required this.subjects,
    required this.selected,
    required this.isLoading,
    required this.onSelected,
  });

  final String label;
  final List<Subject> subjects; // the user's own subjects
  final Subject? selected;
  final bool isLoading;
  final ValueChanged<Subject> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppPickerField<Subject>(
      label: label,
      hint: 'Select subject',
      items: subjects,
      itemLabel: (s) => '${s.name} (${s.code})',
      value: selected,
      isLoading: isLoading,
      onSelected: onSelected,
      // Last row of the picker sheet: search every other subject
      moreLabel: 'More subjects',
      onMore: showSubjectSearchSheet,
    );
  }
}

/// Bottom sheet with a search bar over all subjects of the user's university.
/// Returns the picked subject, or null when dismissed.
Future<Subject?> showSubjectSearchSheet(BuildContext context) {
  final repository = context.read<SubjectsRepository>();
  return showModalBottomSheet<Subject>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (_) => _SubjectSearchSheet(repository: repository),
  );
}

class _SubjectSearchSheet extends StatefulWidget {
  const _SubjectSearchSheet({required this.repository});

  final SubjectsRepository repository;

  @override
  State<_SubjectSearchSheet> createState() => _SubjectSearchSheetState();
}

class _SubjectSearchSheetState extends State<_SubjectSearchSheet> {
  static const _minChars = 4;
  static const _pause = Duration(milliseconds: 300);

  Timer? _debounce;
  int _requestId = 0; // lets a late answer be ignored
  String _query = '';
  List<Subject> _results = const [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    final query = text.trim();
    _requestId++; // drops any search still in flight
    if (query.length < _minChars) {
      setState(() {
        _query = query;
        _results = const [];
        _isLoading = false;
        _error = null;
      });
      return;
    }
    // Wait until the user stops typing before calling the API
    _debounce = Timer(_pause, () => _search(query));
  }

  Future<void> _search(String query) async {
    final id = ++_requestId;
    setState(() {
      _query = query;
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await widget.repository.search(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = const [];
        _isLoading = false;
        _error = e.message;
      });
    }
  }

  Widget _body() {
    if (_isLoading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.lg),
        child: SkeletonSubjectList(count: 4),
      );
    }
    if (_error != null) {
      return _Message(_error!);
    }
    if (_query.length < _minChars) {
      return const _Message('Type at least 4 characters to search.');
    }
    if (_results.isEmpty) {
      return _Message('No subjects found for "$_query".');
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final s = _results[i];
        final detail = [
          s.code,
          s.type,
          if (s.type == 'GE' && s.courseName != null) s.courseName!,
        ].join(' · ');
        return ListTile(
          title: Text(
            s.name,
            style: AppTextStyles.bodySemiBold.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(detail, style: AppTextStyles.caption),
          onTap: () => Navigator.pop(context, s),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      // lift the sheet above the keyboard
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text('Search subjects', style: AppTextStyles.h2),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                autofocus: true,
                onChanged: _onChanged,
                decoration: const InputDecoration(
                  hintText: 'Subject name or code',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium,
      ),
    ),
  );
}
