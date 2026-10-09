import 'package:equatable/equatable.dart';
import '../../../core/models/resource.dart';
import '../../../core/models/subject.dart';

class UploadState extends Equatable {
  const UploadState({
    this.courseId,
    this.semester,
    this.subjects = const [],
    this.selectedSubject,
    this.isLoadingSubjects = false,
    this.type = ResourceType.pyq,
    this.source = ResourceSource.hosted,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  final String? courseId; // null until the profile has loaded
  final int? semester;
  final List<Subject> subjects; // subjects of the chosen semester
  final Subject? selectedSubject;
  final bool isLoadingSubjects;
  final ResourceType type;
  final ResourceSource source; // hosted (file) or externalLink (URL)
  final String? filePath;
  final String? fileName;
  final int? fileSize; // bytes
  final bool isSubmitting;
  final String? error; // one-shot: cleared by the next state
  final bool success; // one-shot: true for a single emit after submitting

  bool get hasFile => filePath != null;

  /// [error] and [success] are NOT copied, so they last for one state only.
  /// Nullable fields use the clear* flags to be set back to null.
  UploadState copyWith({
    String? courseId,
    int? semester,
    List<Subject>? subjects,
    Subject? selectedSubject,
    bool clearSubject = false,
    bool? isLoadingSubjects,
    ResourceType? type,
    ResourceSource? source,
    String? filePath,
    String? fileName,
    int? fileSize,
    bool clearFile = false,
    bool? isSubmitting,
    String? error,
    bool success = false,
  }) {
    return UploadState(
      courseId: courseId ?? this.courseId,
      semester: semester ?? this.semester,
      subjects: subjects ?? this.subjects,
      selectedSubject: clearSubject
          ? null
          : (selectedSubject ?? this.selectedSubject),
      isLoadingSubjects: isLoadingSubjects ?? this.isLoadingSubjects,
      type: type ?? this.type,
      source: source ?? this.source,
      filePath: clearFile ? null : (filePath ?? this.filePath),
      fileName: clearFile ? null : (fileName ?? this.fileName),
      fileSize: clearFile ? null : (fileSize ?? this.fileSize),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success,
    );
  }

  @override
  List<Object?> get props => [
    courseId,
    semester,
    subjects,
    selectedSubject,
    isLoadingSubjects,
    type,
    source,
    filePath,
    fileName,
    fileSize,
    isSubmitting,
    error,
    success,
  ];
}
