import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/subject.dart';
import '../../../core/network/api_exception.dart';

class CurriculumState extends Equatable {
  const CurriculumState({
    required this.selectedSemester,
    this.subjects = const [],
    this.isLoading = false,
    this.error,
  });

  final int selectedSemester;
  final List<Subject> subjects; // subjects of the selected semester
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [selectedSemester, subjects, isLoading, error];
}

/// Which semester is highlighted on the Curriculum screen and the subjects
/// that belong to it. Saving the semester itself is ProfileCubit's job.
class CurriculumCubit extends Cubit<CurriculumState> {
  CurriculumCubit(this._repository, {required this.courseId, required int semester})
      : super(CurriculumState(selectedSemester: semester)) {
    selectSemester(semester);
  }

  final SubjectsRepository _repository;
  final String courseId;

  Future<void> selectSemester(int semester) async {
    emit(CurriculumState(selectedSemester: semester, isLoading: true));
    try {
      final subjects = await _repository.list(courseId: courseId, semester: semester);
      // Ignore a late answer if the user already picked another semester
      if (isClosed || state.selectedSemester != semester) return;
      emit(CurriculumState(selectedSemester: semester, subjects: subjects));
    } on ApiException catch (e) {
      if (isClosed || state.selectedSemester != semester) return;
      emit(CurriculumState(selectedSemester: semester, error: e.message));
    }
  }
}
