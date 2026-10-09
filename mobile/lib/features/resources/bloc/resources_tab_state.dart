import 'package:equatable/equatable.dart';
import '../../../core/models/subject.dart';

class ResourcesTabState extends Equatable {
  const ResourcesTabState({
    this.subjects = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Subject> subjects; // subjects of the user's current semester
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [subjects, isLoading, error];
}
