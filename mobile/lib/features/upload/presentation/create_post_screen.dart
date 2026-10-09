import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/posts_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../community/bloc/create_post_cubit.dart';
import '../../profile/bloc/profile_cubit.dart';

/// The "Create Post" tab: author header, title + content fields and an
/// optional cover image. Calls [onPosted] once the post is created.
class PostComposerPage extends StatelessWidget {
  const PostComposerPage({super.key, this.onPosted});

  final VoidCallback? onPosted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePostCubit(context.read<PostsRepository>()),
      child: _PostComposerView(onPosted: onPosted),
    );
  }
}

class _PostComposerView extends StatefulWidget {
  const _PostComposerView({this.onPosted});

  final VoidCallback? onPosted;

  @override
  State<_PostComposerView> createState() => _PostComposerViewState();
}

class _PostComposerViewState extends State<_PostComposerView> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      context.read<CreatePostCubit>().setCover(picked.path);
    }
  }

  void _submit() => context.read<CreatePostCubit>().submit(
    title: _titleController.text,
    content: _bodyController.text,
  );

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state.profile;
    final name = profile?.fullName ?? '';
    final subtitle = profile == null
        ? ''
        : '${profile.courseName} · ${profile.collegeLabel}';

    return BlocConsumer<CreatePostCubit, CreatePostState>(
      listener: (context, state) {
        if (state.created) {
          _titleController.clear();
          _bodyController.clear();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Posted')));
          widget.onPosted?.call();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) =>
          _buildBody(context, state, name, subtitle, profile?.avatarUrl),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CreatePostState state,
    String name,
    String subtitle,
    String? avatarUrl,
  ) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarCircle(name: name, size: 48, imageUrl: avatarUrl),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.bodySemiBold.copyWith(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: AppTextStyles.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _titleController,
                  maxLines: 1,
                  style: AppTextStyles.h1,
                  decoration:
                      const InputDecoration.collapsed(
                        hintText: 'Add a title',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ).copyWith(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    maxLines: null,
                    expands: true,
                    maxLength: 20000,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTextStyles.bodySemiBold.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                    ),
                    decoration:
                        const InputDecoration.collapsed(
                          hintText:
                              'What do you want to talk to your campus peers about?',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                        ).copyWith(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                    buildCounter:
                        (
                          context, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.coverPath != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: Image.file(
                          File(state.coverPath!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: context
                              .read<CreatePostCubit>()
                              .removeCover,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Add cover image',
                icon: const Icon(
                  Icons.image_outlined,
                  color: AppColors.primary,
                ),
                onPressed: state.isSubmitting ? null : _pickCover,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${_bodyController.text.length}/20000',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              ),
              const Spacer(),
              // "Post" lives here now that the tab has no app bar of its own
              ElevatedButton(
                onPressed: state.isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  elevation: 0,
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
