import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  const Subject({
    required this.id,
    required this.name,
    required this.code,
    this.semester,
    this.credits,
    required this.type,
    required this.courseId,
    this.courseName,
    this.courseShortName,
  });

  final String id;
  final String name;
  final String code;
  final int? semester; // null for subjects not tied to one semester
  final int? credits; // not included when a subject is embedded in a resource
  final String type; // DSC, DSE, SEC, VAC, AEC, GE
  final String courseId;
  final String? courseName; // owning course (the department, for GE)
  final String? courseShortName;

  /// "DBMS" style short label: first letters of the main words, max 4.
  String get shortName {
    // Names without Latin letters (e.g. Hindi) have no sensible initials
    if (!RegExp(r'[A-Za-z]').hasMatch(name)) return code;
    final words = name
        .split(RegExp(r'[\s\-/&]+'))
        .where((w) => w.length > 2 && w[0] == w[0].toUpperCase())
        .toList();
    if (words.length < 2) return name.length <= 6 ? name : name.substring(0, 6);
    return words.take(4).map((w) => w[0]).join().toUpperCase();
  }

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        semester: json['semester'] as int?,
        credits: json['credits'] as int?,
        type: json['type'] as String,
        courseId: json['courseId'] as String,
        courseName: (json['course'] as Map<String, dynamic>?)?['name'] as String?,
        courseShortName:
            (json['course'] as Map<String, dynamic>?)?['shortName'] as String?,
      );

  @override
  List<Object?> get props =>
      [id, name, code, semester, credits, type, courseId, courseName, courseShortName];
}
