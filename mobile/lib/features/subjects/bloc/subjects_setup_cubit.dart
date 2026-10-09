import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/subject.dart';
import '../../../core/models/subjects_form.dart';
import '../../../core/network/api_exception.dart';

class SubjectsSetupState extends Equatable {
  const SubjectsSetupState({
    this.form,
    this.dsc = const [null, null, null],
    this.ge,
    this.dse = const [null, null],
    this.sec,
    this.vac,
    this.aec,
    this.noGe = false,
    this.isLoading = true,
    this.isSaving = false,
    this.error, // load failure: replaces the whole form
    this.formError, // validation / save failure: shown above the button
  });

  final SubjectsForm? form;
  final List<String?> dsc; // 3 slots, ids
  final String? ge;
  final List<String?> dse; // 2 slots, ids (the 2nd only when there is no GE)
  final String? sec;
  final String? vac;
  final String? aec;
  final bool noGe;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? formError;

  SubjectsSetupState copyWith({
    SubjectsForm? form,
    List<String?>? dsc,
    Object? ge = _keep,
    List<String?>? dse,
    Object? sec = _keep,
    Object? vac = _keep,
    Object? aec = _keep,
    bool? noGe,
    bool? isLoading,
    bool? isSaving,
    Object? error = _keep,
    Object? formError = _keep,
  }) =>
      SubjectsSetupState(
        form: form ?? this.form,
        dsc: dsc ?? this.dsc,
        ge: identical(ge, _keep) ? this.ge : ge as String?,
        dse: dse ?? this.dse,
        sec: identical(sec, _keep) ? this.sec : sec as String?,
        vac: identical(vac, _keep) ? this.vac : vac as String?,
        aec: identical(aec, _keep) ? this.aec : aec as String?,
        noGe: noGe ?? this.noGe,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: identical(error, _keep) ? this.error : error as String?,
        formError:
            identical(formError, _keep) ? this.formError : formError as String?,
      );

  @override
  List<Object?> get props =>
      [form, dsc, ge, dse, sec, vac, aec, noGe, isLoading, isSaving, error, formError];
}

const _keep = Object();

/// Drives the "Your subjects" form: loads the pre-filled picks, keeps the
/// dropdown choices and saves them in one request.
class SubjectsSetupCubit extends Cubit<SubjectsSetupState> {
  SubjectsSetupCubit(this._repository) : super(const SubjectsSetupState()) {
    load();
  }

  final SubjectsRepository _repository;

  Future<void> load() async {
    emit(const SubjectsSetupState());
    try {
      final form = await _repository.form();
      if (isClosed) return;
      final dsc = form.selectedFor('dsc');
      final dse = form.selectedFor('dse');
      final ge = form.selectedFor('ge');
      emit(SubjectsSetupState(
        form: form,
        isLoading: false,
        dsc: [for (var i = 0; i < 3; i++) i < dsc.length ? dsc[i] : null],
        ge: ge.isEmpty ? null : ge.first,
        dse: [for (var i = 0; i < 2; i++) i < dse.length ? dse[i] : null],
        sec: form.selectedFor('sec').firstOrNull,
        vac: form.selectedFor('vac').firstOrNull,
        aec: form.selectedFor('aec').firstOrNull,
        noGe: ge.isEmpty && dse.length == 2,
      ));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(SubjectsSetupState(isLoading: false, error: e.message));
    }
  }

  void setDsc(int slot, String? id) {
    final next = [...state.dsc]..[slot] = id;
    emit(state.copyWith(dsc: next, formError: null));
  }

  void setDse(int slot, String? id) {
    final next = [...state.dse]..[slot] = id;
    emit(state.copyWith(dse: next, formError: null));
  }

  void setGe(String? id) => emit(state.copyWith(ge: id, formError: null));
  void setSec(String? id) => emit(state.copyWith(sec: id, formError: null));
  void setVac(String? id) => emit(state.copyWith(vac: id, formError: null));
  void setAec(String? id) => emit(state.copyWith(aec: id, formError: null));

  void setNoGe(bool value) => emit(state.copyWith(
        noGe: value,
        ge: value ? null : state.ge,
        // the second DSE slot only exists without a GE
        dse: value ? state.dse : [state.dse[0], null],
        formError: null,
      ));

  /// Returns true when saved. Failures land in [SubjectsSetupState.formError].
  Future<bool> save() async {
    final dsc = state.dsc.whereType<String>().toList();
    final dse = state.dse.whereType<String>().toList();

    String? problem;
    if (dsc.isEmpty) {
      problem = 'Select your DSC subjects.';
    } else if (dsc.toSet().length != dsc.length) {
      problem = 'DSC subjects must be different.';
    } else if (dse.toSet().length != dse.length) {
      problem = 'DSE subjects must be different.';
    }
    if (problem != null) {
      emit(state.copyWith(formError: problem));
      return false;
    }

    emit(state.copyWith(isSaving: true, formError: null));
    try {
      await _repository.saveMine(
        dsc: dsc,
        ge: state.noGe ? null : state.ge,
        dse: dse,
        sec: state.sec,
        vac: state.vac,
        aec: state.aec,
      );
      if (isClosed) return false;
      emit(state.copyWith(isSaving: false));
      return true;
    } on ApiException catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(isSaving: false, formError: e.message));
      return false;
    }
  }

  Subject? subjectById(String? id) {
    if (id == null || state.form == null) return null;
    for (final list in state.form!.options.values) {
      for (final s in list) {
        if (s.id == id) return s;
      }
    }
    return null;
  }
}
