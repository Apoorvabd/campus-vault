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

  /// "Add+" opens a small menu: take a photo with the camera, or pick one
  /// from the gallery.
  Future<void> _showAddMenu() async {
    final hasCover = context.read<CreatePostCubit>().state.coverPath != null;
    final choice = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, 'camera'),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, 'gallery'),
            ),
            if (hasCover)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(sheetContext, 'remove'),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'camera':
        await _pickCover(ImageSource.camera);
      case 'gallery':
        await _pickCover(ImageSource.gallery);
      case 'remove':
        context.read<CreatePostCubit>().removeCover();
    }
  }

  Future<void> _pickCover(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        context.read<CreatePostCubit>().setCover(picked.path);
      }
    } catch (_) {
      // No camera, or permission denied
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Could not open the camera. Check the camera permission.'
                  : 'Could not open your gallery.',
            ),
          ),
        );
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
              // Clearly visible "Add+" pill instead of a small bare icon
              Material(
                color: AppColors.primaryLight,
                shape: const StadiumBorder(
                  side: BorderSide(color: AppColors.primary, width: 1.2),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: state.isSubmitting ? null : _showAddMenu,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Add+',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
