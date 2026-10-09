import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/data/profile_repository.dart';
import '../../../core/models/profile.dart';
import '../../../core/network/api_exception.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final Profile? profile; // null until the first load succeeds
  final bool isLoading; // initial load or refresh
  final bool isSaving; // edit / avatar request in flight
  final String? error; // last error message; cleared by the next state

  @override
  List<Object?> get props => [profile, isLoading, isSaving, error];
}

/// The logged-in user's profile. Provided once for the whole app, so Home,
/// Profile, Create Post and Curriculum all read the same data.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(ProfileState(profile: state.profile, isLoading: true));
    try {
      final profile = await _repository.getMe();
      if (isClosed) return;
      emit(ProfileState(profile: profile));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ProfileState(profile: state.profile, error: e.message));
    }
  }

  /// Forget everything (on logout).
  void clear() => emit(const ProfileState());

  Future<bool> update({
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    String? headline,
    int? currentSemester,
  }) =>
      _save(() => _repository.update(
            firstName: firstName,
            lastName: lastName,
            username: username,
            bio: bio,
            headline: headline,
            currentSemester: currentSemester,
          ));

  Future<bool> setAvatar(String imagePath) =>
      _save(() => _repository.uploadAvatar(imagePath));

  Future<bool> removeAvatar() => _save(_repository.removeAvatar);

  /// Runs a save request; returns true on success so the screen can react.
  Future<bool> _save(Future<Profile> Function() request) async {
    final before = state.profile;
    emit(ProfileState(profile: before, isSaving: true));
    try {
      final updated = await request();
      if (isClosed) return false;
      // Edit responses carry no stats, so keep the ones we already have
      emit(ProfileState(profile: updated.withStatsFrom(before)));
      return true;
    } on ApiException catch (e) {
      if (isClosed) return false;
      emit(ProfileState(profile: before, error: e.message));
      return false;
    }
  }
}
