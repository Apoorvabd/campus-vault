import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/network/api_exception.dart';

class CreatePostState extends Equatable {
  const CreatePostState({
    this.coverPath,
    this.isSubmitting = false,
    this.error,
    this.created = false,
  });

  final String? coverPath; // local path of the chosen cover image
  final bool isSubmitting;
  final String? error;
  final bool created; // true once the post is saved

  @override
  List<Object?> get props => [coverPath, isSubmitting, error, created];
}

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(this._repository) : super(const CreatePostState());

  final PostsRepository _repository;

  void setCover(String path) => emit(CreatePostState(coverPath: path));

  void removeCover() => emit(const CreatePostState());

  Future<void> submit({required String title, required String content}) async {
    final t = title.trim();
    final c = content.trim();
    if (t.isEmpty || c.isEmpty) {
      emit(CreatePostState(
        coverPath: state.coverPath,
        error: 'Please add a title and some content',
      ));
      return;
    }
    emit(CreatePostState(coverPath: state.coverPath, isSubmitting: true));
    try {
      await _repository.create(
        title: t,
        content: c,
        coverImagePath: state.coverPath,
      );
      if (isClosed) return;
      emit(CreatePostState(coverPath: state.coverPath, created: true));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(CreatePostState(coverPath: state.coverPath, error: e.message));
    }
  }
}
