import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/resource.dart';
import '../../../core/models/subject.dart';
import '../data/local_vault_item.dart';
import '../data/local_vault_repository.dart';
import 'local_vault_state.dart';

/// The on-device vault. Created once in main() so the Saved screen and the
/// Storage screen both see the same list.
class LocalVaultCubit extends Cubit<LocalVaultState> {
  LocalVaultCubit(this._repo) : super(const LocalVaultState());

  final LocalVaultRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      emit(LocalVaultState(items: await _repo.list()));
    } catch (_) {
      emit(
        state.copyWith(isLoading: false, error: 'Could not read your files.'),
      );
    }
  }

  /// Returns true when the file was saved.
  Future<bool> add({
    required String sourcePath,
    required String fileName,
    required String title,
    required ResourceType type,
    required Subject subject,
  }) async {
    try {
      final item = await _repo.add(
        sourcePath: sourcePath,
        fileName: fileName,
        title: title,
        type: type,
        subject: subject,
      );
      emit(state.copyWith(items: [item, ...state.items]));
      return true;
    } catch (_) {
      emit(state.copyWith(error: 'Could not save the file on this device.'));
      return false;
    }
  }

  Future<void> delete(LocalVaultItem item) async {
    try {
      await _repo.delete(item);
      emit(
        state.copyWith(
          items: state.items.where((e) => e.id != item.id).toList(),
        ),
      );
    } catch (_) {
      emit(state.copyWith(error: 'Could not delete the file.'));
    }
  }

  Future<String> pathOf(LocalVaultItem item) async =>
      (await _repo.fileFor(item)).path;
}
