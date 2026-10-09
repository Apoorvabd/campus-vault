import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/subject.dart';
import '../../../app_navigation.dart';
import '../../../core/widgets/keep_alive_wrapper.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/resource.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_shell_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/upload_cubit.dart';
import 'subject_picker.dart';
import 'save_choice_sheet.dart';
import '../../local_vault/bloc/local_vault_cubit.dart';
import '../bloc/upload_state.dart';
import 'create_post_screen.dart';

/// Add screen (bottom nav "+"): two swipeable tabs, "Add Document" and
/// "Create Post", styled and sliding like Community / Resources on Home.
class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({
    super.key,
    this.initialSubject,
    this.initialTab = 0,
  });

  /// Pre-selects the subject (e.g. when opened from a Subject Detail screen).
  final Subject? initialSubject;

  /// 0 = Add Document, 1 = Create Post.
  final int initialTab;

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen>
    with SingleTickerProviderStateMixin {
  static const _navIndex = 2;

  // Shared by the tab bar and the pages: dragging the pages moves the bar
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      currentIndex: _navIndex,
      onSearchTap: () => openSearch(context),
      onNavTap: (index) {
        if (index == _navIndex) return;
        goToTab(context, index);
      },
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(height: 1, thickness: 1.2, color: AppColors.border),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              0,
            ),
            child: SegmentedTabs(
              controller: _tabs,
              labels: const ['Add Document', 'Create Post'],
              icons: const [
                Icons.note_add_outlined,
                Icons.dynamic_feed_outlined,
              ],
              height: 38,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                KeepAliveWrapper(
                  child: _DocumentPage(initialSubject: widget.initialSubject),
                ),
                // After posting, go to Home so the new post shows in the feed
                KeepAliveWrapper(
                  child: PostComposerPage(onPosted: () => goToTab(context, 0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Add Document" tab: pick a subject, a category, then upload a file or
/// share a link. New resources wait for admin approval before others see them.
class _DocumentPage extends StatefulWidget {
  const _DocumentPage({this.initialSubject});

  final Subject? initialSubject;

  @override
  State<_DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<_DocumentPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  late final UploadCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = UploadCubit(
      context.read<ResourcesRepository>(),
      context.read<SubjectsRepository>(),
      initialSubject: widget.initialSubject,
    );
    _cubit.start();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _cubit.close();
    super.dispose();
  }

  bool _savingLocally = false;

  /// Checks the form, then asks whether to upload online or keep the file on
  /// this device.
  Future<void> _onSavePressed() async {
    final problem = _cubit.validationProblem(
      title: _titleController.text,
      url: _urlController.text,
    );
    if (problem != null) {
      _showMessage(problem);
      return;
    }

    final isLink = _cubit.state.source == ResourceSource.externalLink;
    final choice = await showSaveChoiceSheet(context, canSaveLocally: !isLink);
    if (!mounted || choice == null) return;

    switch (choice) {
      case SaveChoice.online:
        _cubit.submit(
          title: _titleController.text,
          description: _descriptionController.text,
          url: _urlController.text,
        );
      case SaveChoice.local:
        await _saveOnDevice();
    }
  }

  Future<void> _saveOnDevice() async {
    final form = _cubit.state;
    final subject = form.selectedSubject;
    if (subject == null || !form.hasFile) return;

    setState(() => _savingLocally = true);
    final saved = await context.read<LocalVaultCubit>().add(
      sourcePath: form.filePath!,
      fileName: form.fileName ?? 'file',
      title: _titleController.text.trim(),
      type: form.type,
      subject: subject,
    );
    if (!mounted) return;
    setState(() => _savingLocally = false);

    if (saved) {
      _titleController.clear();
      _descriptionController.clear();
      _urlController.clear();
      _cubit.removeFile();
      _showMessage('Saved on this device. You can find it under Saved.');
    } else {
      _showMessage('Could not save the file on this device.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<UploadCubit, UploadState>(
            listener: (context, state) {
              if (state.error != null) _showMessage(state.error!);
              if (state.success) {
                _titleController.clear();
                _descriptionController.clear();
                _urlController.clear();
                _showMessage(
                  'Submitted for review — it will appear once approved',
                );
              }
            },
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.lg),
            _buildDetailsCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildFileCard(),
            const SizedBox(height: AppSpacing.xl),
            BlocBuilder<UploadCubit, UploadState>(
              builder: (context, state) => AppButton(
                label: state.isSubmitting
                    ? 'Uploading...'
                    : (_savingLocally
                          ? 'Saving...'
                          : 'Upload and Save Document'),
                icon: Icons.arrow_forward,
                onPressed: state.isSubmitting || _savingLocally
                    ? null
                    : _onSavePressed,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'New uploads are reviewed by an admin before they are visible to others.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _SectionCard(
      icon: Icons.assignment_outlined,
      title: 'Academic Classification & Details',
      children: [
        AppTextField(
          label: 'Document Name / Title *',
          hint: 'DBMS End-Sem Solved Papers & Unit 3 Notes',
          controller: _titleController,
        ),
        const SizedBox(height: AppSpacing.lg),
        // Course is read-only: always the user's own course
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => _ReadOnlyField(
            label: 'Course / Degree',
            value: state.profile?.courseName ?? 'Loading...',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BlocBuilder<UploadCubit, UploadState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubjectPickerField(
                  label: 'Subject Name / Code *',
                  subjects: state.subjects,
                  selected: state.selectedSubject,
                  isLoading: state.isLoadingSubjects,
                  onSelected: _cubit.selectSubject,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Resource Category *',
                  style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final type in ResourceType.values)
                      _CategoryChip(
                        label: type.label,
                        selected: type == state.type,
                        onTap: () => _cubit.selectType(type),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Description (optional)',
          hint: 'Anything that helps others, e.g. exam year or unit covered',
          controller: _descriptionController,
        ),
      ],
    );
  }

  Widget _buildFileCard() {
    return BlocBuilder<UploadCubit, UploadState>(
      builder: (context, state) {
        final isLink = state.source == ResourceSource.externalLink;
        return _SectionCard(
          icon: Icons.attach_file,
          title: 'Resource File',
          titleTrailing: !isLink && state.hasFile
              ? GestureDetector(
                  onTap: _cubit.pickFile,
                  child: Text(
                    'Change file',
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                )
              : null,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ModeToggle(
                    label: 'Upload file',
                    icon: Icons.upload_file_outlined,
                    selected: !isLink,
                    onTap: () => _cubit.selectSource(ResourceSource.hosted),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ModeToggle(
                    label: 'External link',
                    icon: Icons.link,
                    selected: isLink,
                    onTap: () =>
                        _cubit.selectSource(ResourceSource.externalLink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isLink)
              AppTextField(
                label: 'Link *',
                hint: 'https://drive.google.com/...',
                controller: _urlController,
                keyboardType: TextInputType.url,
              )
            else ...[
              if (state.hasFile)
                _FileTile(
                  name: state.fileName ?? 'file',
                  size: state.fileSize ?? 0,
                  onRemove: _cubit.removeFile,
                )
              else
                AppButton(
                  label: 'Choose file',
                  icon: Icons.upload_file_outlined,
                  variant: AppButtonVariant.outline,
                  onPressed: _cubit.pickFile,
                ),
              const SizedBox(height: AppSpacing.md),
              Text('PDF, JPG, PNG · max 15 MB', style: AppTextStyles.caption),
            ],
          ],
        );
      },
    );
  }
}

String _formatSize(int bytes) {
  final mb = bytes / (1024 * 1024);
  if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
  return '${(bytes / 1024).ceil()} KB';
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.name,
    required this.size,
    required this.onRemove,
  });

  final String name;
  final int size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isPdf = name.toLowerCase().endsWith('.pdf');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.iconBox),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${_formatSize(size)} · ',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      'Ready to upload',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySemiBold.copyWith(
            fontSize: 13,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            value,
            style: AppTextStyles.bodySemiBold.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontSize: 14,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.titleTrailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15)),
                ],
              ),
              ?titleTrailing,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}
