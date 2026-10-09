import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/resource.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../upload/bloc/upload_cubit.dart';
import '../../upload/presentation/subject_picker.dart';
import '../../upload/bloc/upload_state.dart';
import '../bloc/local_vault_cubit.dart';

/// Bottom sheet: pick semester + subject + category + file, then copy the
/// file into the on-device vault. [initialSubject] pre-selects the subject
/// (e.g. when opened from a Subject Detail screen).
Future<void> showAddLocalFileSheet(
  BuildContext context, {
  Subject? initialSubject,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true, // keeps a tall sheet out from under the status bar
    backgroundColor: AppColors.surface,
    builder: (_) => _AddLocalFileSheet(initialSubject: initialSubject),
  );
}

class _AddLocalFileSheet extends StatefulWidget {
  const _AddLocalFileSheet({this.initialSubject});

  final Subject? initialSubject;

  @override
  State<_AddLocalFileSheet> createState() => _AddLocalFileSheetState();
}

class _AddLocalFileSheetState extends State<_AddLocalFileSheet> {
  final _titleController = TextEditingController();

  // Reuses the Add Document form logic (semester -> subjects, category,
  // file picking + size/type checks). We never call its submit(): saving
  // goes to the LocalVaultCubit instead of the server.
  late final UploadCubit _form;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _form = UploadCubit(
      context.read<ResourcesRepository>(),
      context.read<SubjectsRepository>(),
      initialSubject: widget.initialSubject,
    );
    _form.start();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _form.close();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save(UploadState form) async {
    final subject = form.selectedSubject;
    if (subject == null) return _showMessage('Please choose a subject.');
    if (!form.hasFile) return _showMessage('Please choose a file.');

    // No title typed -> use the file name without its extension
    final name = form.fileName ?? 'file';
    final dot = name.lastIndexOf('.');
    final typed = _titleController.text.trim();
    final title = typed.isNotEmpty
        ? typed
        : (dot > 0 ? name.substring(0, dot) : name);

    setState(() => _saving = true);
    final saved = await context.read<LocalVaultCubit>().add(
      sourcePath: form.filePath!,
      fileName: name,
      title: title,
      type: form.type,
      subject: subject,
    );
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _form,
      child: BlocListener<UploadCubit, UploadState>(
        listenWhen: (_, now) => now.error != null,
        listener: (context, state) => _showMessage(state.error!),
        child: Padding(
          // Lift the sheet above the keyboard, or above the system navigation
          // bar when the keyboard is closed (so the Save button isn't hidden)
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? MediaQuery.of(context).viewInsets.bottom
                : MediaQuery.of(context).viewPadding.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BlocBuilder<UploadCubit, UploadState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Save file on this device', style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(
                      'A private copy is kept in the app, so it opens offline '
                      'even if the original is deleted.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SubjectPickerField(
                      label: 'Subject *',
                      subjects: state.subjects,
                      selected: state.selectedSubject,
                      isLoading: state.isLoadingSubjects,
                      onSelected: _form.selectSubject,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Category *',
                      style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final type in ResourceType.values)
                          ChoiceChip(
                            label: Text(type.label),
                            selected: type == state.type,
                            onSelected: (_) => _form.selectType(type),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Title (optional)',
                      hint: 'Defaults to the file name',
                      controller: _titleController,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.hasFile)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: AppColors.error,
                        ),
                        title: Text(
                          state.fileName ?? 'file',
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _form.removeFile,
                        ),
                      )
                    else
                      AppButton(
                        label: 'Choose file',
                        icon: Icons.upload_file_outlined,
                        variant: AppButtonVariant.outline,
                        onPressed: _form.pickFile,
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: _saving ? 'Saving...' : 'Save on device',
                      icon: Icons.download_done_outlined,
                      onPressed: _saving ? null : () => _save(state),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
