import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/network/api_exception.dart';
import 'resources_tab_state.dart';

/// Data for the Resources tab: this semester's subjects.
class ResourcesTabCubit extends Cubit<ResourcesTabState> {
  ResourcesTabCubit(this._subjects) : super(const ResourcesTabState());

  final SubjectsRepository _subjects;

  Future<void> load() async {
    emit(const ResourcesTabState(isLoading: true));
    try {
      final subjects = await _subjects.mine();
      if (isClosed) return;
      emit(ResourcesTabState(subjects: subjects));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ResourcesTabState(error: e.message));
    }
  }
}
