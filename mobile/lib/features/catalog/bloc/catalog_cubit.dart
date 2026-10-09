import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/catalog_models.dart';
import '../data/catalog_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState());

  final CatalogRepository _repository;

  /// Loads the universities, picks Delhi University for the user and loads its
  /// colleges and courses. No loading flags are set: the pickers just fill in.
  Future<void> start() async {
    try {
      final universities = await _repository.getUniversities();
      if (isClosed) return;
      emit(state.copyWith(universities: universities));
      final university = CatalogRepository.defaultUniversity(universities);
      if (university != null) await selectUniversity(university);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(error: e.message));
    }
  }

  Future<void> loadUniversities() async {
    emit(state.copyWith(isLoadingUniversities: true));
    try {
      final universities = await _repository.getUniversities();
      if (isClosed) return;
      emit(
        state.copyWith(
          universities: universities,
          isLoadingUniversities: false,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingUniversities: false, error: e.message));
    }
  }

  Future<void> selectUniversity(University university) async {
    if (university == state.selectedUniversity) return;

    // A new university makes the old college and course invalid,
    // so build a fresh state instead of copyWith (which would keep them)
    emit(
      CatalogState(
        universities: state.universities,
        selectedUniversity: university,
      ),
    );

    try {
      // Both requests run at the same time
      final results = await Future.wait([
        _repository.getColleges(university.id),
        _repository.getCourses(university.id),
      ]);

      // Stop if the screen closed, or the user already picked another university
      if (isClosed || state.selectedUniversity != university) return;

      emit(
        state.copyWith(
          colleges: results[0] as List<College>,
          courses: results[1] as List<Course>,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed || state.selectedUniversity != university) return;
      emit(state.copyWith(error: e.message));
    }
  }

  void selectCollege(College college) =>
      emit(state.copyWith(selectedCollege: college));

  void selectCourse(Course course) =>
      emit(state.copyWith(selectedCourse: course));
}
