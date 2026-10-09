import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/resource.dart';
import '../../../core/models/subject.dart';
import '../../../core/network/api_exception.dart';
import 'upload_state.dart';

/// Form + submit state of the "Add Document" screen.
/// (Title, description and URL live in the screen's text controllers and are
/// handed to [submit].)
class UploadCubit extends Cubit<UploadState> {
  UploadCubit(this._resources, this._subjects, {this.initialSubject})
    : super(const UploadState());

  static const maxFileBytes = 15 * 1024 * 1024; // server limit: 15 MB
  static const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  final ResourcesRepository _resources;
  final SubjectsRepository _subjects;
  final Subject? initialSubject;

  /// Loads the user's own subjects for the dropdown (safe to call again, it
  /// only starts once). Any other subject is reachable through the search
  /// sheet, see [selectSubject].
  void start() {
    if (_started) return;
    _started = true;
    _loadSubjects(preselect: initialSubject);
  }

  bool _started = false;

  Future<void> _loadSubjects({Subject? preselect}) async {
    emit(state.copyWith(isLoadingSubjects: true));
    try {
      final subjects = await _subjects.mine();
      if (isClosed) return;

      // Match by id so the picker highlights the item from the loaded list
      Subject? selected;
      if (preselect != null) {
        for (final s in subjects) {
          if (s.id == preselect.id) selected = s;
        }
        selected ??= preselect;
      }
      emit(
        state.copyWith(
          subjects: subjects,
          selectedSubject: selected,
          isLoadingSubjects: false,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingSubjects: false, error: e.message));
    }
  }

  void selectSubject(Subject subject) =>
      emit(state.copyWith(selectedSubject: subject));

  void selectType(ResourceType type) => emit(state.copyWith(type: type));

  void selectSource(ResourceSource source) =>
      emit(state.copyWith(source: source));

  Future<void> pickFile() async {
    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
    } catch (_) {
      if (!isClosed)
        emit(state.copyWith(error: 'Could not open the file picker.'));
      return;
    }
    if (isClosed || file == null) return; // user cancelled

    final path = file.path;
    final extension = (file.extension ?? '').toLowerCase();
    final size = file.lengthSync() ?? await file.length() ?? 0;
    if (isClosed) return;

    if (path == null || !allowedExtensions.contains(extension)) {
      emit(state.copyWith(error: 'Only PDF, JPG or PNG files are supported.'));
    } else if (size > maxFileBytes) {
      emit(
        state.copyWith(error: 'File is too large. The maximum size is 15 MB.'),
      );
    } else {
      emit(state.copyWith(filePath: path, fileName: file.name, fileSize: size));
    }
  }

  void removeFile() => emit(state.copyWith(clearFile: true));

  /// The first thing wrong with the form, or null when it can be saved.
  /// Shared by the online upload and the save-on-device path.
  String? validationProblem({required String title, required String url}) {
    final isLink = state.source == ResourceSource.externalLink;
    if (title.trim().isEmpty) return 'Please enter a title.';
    if (state.selectedSubject == null) return 'Please choose a subject.';
    if (isLink && !_isValidUrl(url.trim())) {
      return 'Enter a valid link starting with http:// or https://';
    }
    if (!isLink && !state.hasFile) return 'Please choose a file to upload.';
    return null;
  }

  Future<void> submit({
    required String title,
    required String description,
    required String url,
  }) async {
    if (state.isSubmitting) return;
    final isLink = state.source == ResourceSource.externalLink;

    // Validate before calling the API
    final problem = validationProblem(title: title, url: url);
    if (problem != null) {
      emit(state.copyWith(error: problem));
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    try {
      await _resources.create(
        title: title.trim(),
        description: description.trim(),
        type: state.type,
        subjectId: state.selectedSubject!.id,
        source: state.source,
        externalUrl: isLink ? url.trim() : null,
        filePath: isLink ? null : state.filePath,
      );
      if (isClosed) return;
      // Reset the form but keep semester + subject for the next upload
      emit(
        state.copyWith(
          isSubmitting: false,
          type: ResourceType.pyq,
          source: ResourceSource.hosted,
          clearFile: true,
          success: true,
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      final message = e.statusCode == 409
          ? 'This link has already been added for this subject.'
          : e.message;
      emit(state.copyWith(isSubmitting: false, error: message));
    }
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
