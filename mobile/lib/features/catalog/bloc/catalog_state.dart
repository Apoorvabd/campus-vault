import 'package:equatable/equatable.dart';
import '../data/catalog_models.dart';

class CatalogState extends Equatable {
  const CatalogState({
    this.universities = const [],
    this.colleges = const [],
    this.courses = const [],
    this.selectedUniversity,
    this.selectedCollege,
    this.selectedCourse,
    this.isLoadingUniversities = false,
    this.isLoadingOptions = false,
    this.error,
  });

  final List<University> universities;
  final List<College> colleges;
  final List<Course> courses;

  final University? selectedUniversity;
  final College? selectedCollege;
  final Course? selectedCourse;

  final bool isLoadingUniversities;
  final bool isLoadingOptions; // colleges and courses of the chosen university
  final String? error;

  // True when the user has picked everything register needs
  bool get isComplete =>
      selectedUniversity != null &&
      selectedCollege != null &&
      selectedCourse != null;

  // Copy this state, changing only what you pass in.
  // Note: `error` is NOT kept, so every new state clears the old error
  // unless you pass a new one.
  CatalogState copyWith({
    List<University>? universities,
    List<College>? colleges,
    List<Course>? courses,
    University? selectedUniversity,
    College? selectedCollege,
    Course? selectedCourse,
    bool? isLoadingUniversities,
    bool? isLoadingOptions,
    String? error,
  }) {
    return CatalogState(
      universities: universities ?? this.universities,
      colleges: colleges ?? this.colleges,
      courses: courses ?? this.courses,
      selectedUniversity: selectedUniversity ?? this.selectedUniversity,
      selectedCollege: selectedCollege ?? this.selectedCollege,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      isLoadingUniversities:
          isLoadingUniversities ?? this.isLoadingUniversities,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    universities,
    colleges,
    courses,
    selectedUniversity,
    selectedCollege,
    selectedCourse,
    isLoadingUniversities,
    isLoadingOptions,
    error,
  ];
}
