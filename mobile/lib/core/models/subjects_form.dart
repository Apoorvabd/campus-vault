import 'package:equatable/equatable.dart';
import 'subject.dart';

/// What the "Your subjects" form needs (GET /subjects/form): the user's
/// current picks plus the dropdown options for every subject type.
class SubjectsForm extends Equatable {
  const SubjectsForm({
    required this.semester,
    required this.confirmed,
    required this.selected,
    required this.options,
  });

  final int semester;
  final bool confirmed; // true once the user saved the form for this semester
  final Map<String, List<String>> selected; // type -> picked subject ids
  final Map<String, List<Subject>> options; // type -> dropdown subjects

  List<Subject> optionsFor(String type) => options[type] ?? const [];
  List<String> selectedFor(String type) => selected[type] ?? const [];

  factory SubjectsForm.fromJson(Map<String, dynamic> json) {
    const types = ['dsc', 'ge', 'dse', 'sec', 'vac', 'aec'];
    final sel = json['selected'] as Map<String, dynamic>;
    final opt = json['options'] as Map<String, dynamic>;
    return SubjectsForm(
      semester: (json['semester'] as num).toInt(),
      confirmed: json['confirmed'] as bool? ?? false,
      selected: {
        for (final t in types)
          t: switch (sel[t]) {
            null => <String>[],
            final List l => l.cast<String>(),
            final String s => [s],
            _ => <String>[],
          },
      },
      options: {
        for (final t in types)
          t: ((opt[t] as List?) ?? const [])
              .map((e) => Subject.fromJson(e as Map<String, dynamic>))
              .toList(),
      },
    );
  }

  @override
  List<Object?> get props => [semester, confirmed, selected, options];
}
