import 'package:equatable/equatable.dart';

class University extends Equatable {
  const University({
    required this.id,
    required this.name,
    required this.shortName,
  });

  final String id;
  final String name;
  final String shortName;

  factory University.fromJson(Map<String, dynamic> json) => University(
    id: json['id'] as String,
    name: json['name'] as String,
    shortName: json['shortName'] as String,
  );

  @override
  List<Object?> get props => [id, name, shortName];
}

class College extends Equatable {
  const College({required this.id, required this.name, this.shortName});

  final String id;
  final String name;
  final String? shortName; // nullable in the database

  factory College.fromJson(Map<String, dynamic> json) => College(
    id: json['id'] as String,
    name: json['name'] as String,
    shortName: json['shortName'] as String?,
  );

  @override
  List<Object?> get props => [id, name, shortName];
}

class Course extends Equatable {
  const Course({
    required this.id,
    required this.name,
    this.shortName,
    required this.totalSemesters,
  });

  final String id;
  final String name;
  final String? shortName;
  final int totalSemesters; // lets the semester grid match the chosen course

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String,
    name: json['name'] as String,
    shortName: json['shortName'] as String?,
    totalSemesters: json['totalSemesters'] as int,
  );

  @override
  List<Object?> get props => [id, name, shortName, totalSemesters];
}
