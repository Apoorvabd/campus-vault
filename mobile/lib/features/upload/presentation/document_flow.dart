import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/resources_repository.dart';
import '../../../core/data/subjects_repository.dart';
import '../../../core/models/resource.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../local_vault/bloc/local_vault_cubit.dart';
import '../bloc/upload_cubit.dart';
import '../bloc/upload_state.dart';
import 'save_choice_sheet.dart';
import 'subject_picker.dart';

/// The "Add Document" tab, in two steps:
///  1. add the document (file, photo, camera shot or link)
///  2. its details (title, subject, category, description), then save.
/// [onStepChanged] tells the parent which step is showing, so it can hide the
/// tab bar and handle Back while on step 2.
class DocumentFlowPage extends StatefulWidget {
  const DocumentFlowPage({super.key, this.initialSubject, this.onStepChanged});

  final Subject? initialSubject;
  final ValueChanged<int>? onStepChanged;

  @override
  State<DocumentFlowPage> createState() => DocumentFlowPageState();
}

enum _Picked { files, photos, camera }

class DocumentFlowPageState extends State<DocumentFlowPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  late final UploadCubit _cubit;

  int _step = 1;
  _Picked _picked = _Picked.files; // which tile the current file came from
  bool _savingLocally = false;

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

  /// Back from step 2 to step 1. Returns true when it handled the press.
  bool goBack() {
    if (_step == 1) return false;
    _setStep(1);
    return true;
  }

  void _setStep(int step) {
    setState(() => _step = step);
    widget.onStepChanged?.call(step);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- step 1: pick what to add -------------------------------------------

  Future<void> _pickFiles() async {
    _cubit.selectSource(ResourceSource.hosted);
    await _cubit.pickFile();
    if (mounted && _cubit.state.hasFile)
      setState(() => _picked = _Picked.files);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    _cubit.selectSource(ResourceSource.hosted);
    await _cubit.pickPhoto(source);
    if (mounted && _cubit.state.hasFile) {
      setState(() {
        _picked = source == ImageSource.camera
            ? _Picked.camera
            : _Picked.photos;
      });
    }
  }

  void _chooseLink() {
    _cubit.removeFile();
    _cubit.selectSource(ResourceSource.externalLink);
  }

  void _onNext() {
    final problem = _cubit.fileProblem(url: _urlController.text);
    if (problem != null) {
      _showMessage(problem);
      return;
    }
    FocusScope.of(context).unfocus();
    _setStep(2);
  }

  // ---- step 2: save --------------------------------------------------------

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
      _resetForm();
      _showMessage('Saved on this device. You can find it under Saved.');
    } else {
      _showMessage('Could not save the file on this device.');
    }
  }

  /// Back to a clean step 1, ready for the next document.
  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _urlController.clear();
    _cubit.removeFile();
    _cubit.selectSource(ResourceSource.hosted);
    _setStep(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state.error != null) _showMessage(state.error!);
          if (state.success) {
            _resetForm();
            _showMessage('Submitted for review — it will appear once approved');
          }
        },
        builder: (context, state) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: _step == 1 ? _buildStep1(state) : _buildStep2(state),
        ),
      ),
    );
  }

  List<Widget> _buildStep1(UploadState state) {
    final isLink = state.source == ResourceSource.externalLink;
    final fileName = state.fileName;
    return [
      const _Stepper(step: 1),
      const SizedBox(height: AppSpacing.lg),
      const _HeroCard(),
      const SizedBox(height: AppSpacing.xl),
      Text('CHOOSE HOW TO ADD', style: AppTextStyles.overline),
      const SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(
            child: _SourceTile(
              icon: Icons.folder_outlined,
              color: AppColors.primary,
              title: 'Files',
              subtitle: 'PDF from your phone',
              selected: !isLink && state.hasFile && _picked == _Picked.files,
              onTap: _pickFiles,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _SourceTile(
              icon: Icons.photo_outlined,
              color: AppColors.accentPurple,
              title: 'Photos',
              subtitle: 'Pick from gallery',
              selected: !isLink && state.hasFile && _picked == _Picked.photos,
              onTap: () => _pickPhoto(ImageSource.gallery),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(
            child: _SourceTile(
              icon: Icons.photo_camera_outlined,
              color: const Color(0xFF0F9D8F),
              title: 'Camera',
              subtitle: 'Snap a page',
              selected: !isLink && state.hasFile && _picked == _Picked.camera,
              onTap: () => _pickPhoto(ImageSource.camera),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _SourceTile(
              icon: Icons.link,
              color: AppColors.accentOrange,
              title: 'Link',
              subtitle: 'Drive, Dropbox...',
              selected: isLink,
              onTap: _chooseLink,
            ),
          ),
        ],
      ),
      if (isLink) ...[
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'https://drive.google.com/...',
            prefixIcon: Icon(Icons.link),
          ),
        ),
      ] else if (state.hasFile) ...[
        const SizedBox(height: AppSpacing.lg),
        _FileCard(
          name: fileName ?? 'file',
          detail: 'Ready to upload · ${_formatSize(state.fileSize ?? 0)}',
          kind: _kindOf(fileName),
          actionLabel: 'Remove',
          onAction: _cubit.removeFile,
          highlighted: true,
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'New uploads are reviewed by an admin before others can see them.',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      AppButton(label: 'Next', icon: Icons.arrow_forward, onPressed: _onNext),
    ];
  }

  List<Widget> _buildStep2(UploadState state) {
    final isLink = state.source == ResourceSource.externalLink;
    final busy = state.isSubmitting || _savingLocally;
    return [
      Row(
        children: [
          GestureDetector(
            onTap: goBack,
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('Add details', style: AppTextStyles.h1.copyWith(fontSize: 20)),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      const _Stepper(step: 2),
      const SizedBox(height: AppSpacing.lg),
      _FileCard(
        name: isLink ? _urlController.text.trim() : (state.fileName ?? 'file'),
        detail: isLink
            ? 'External link'
            : '${_formatSize(state.fileSize ?? 0)} · ${_kindLabel(state.fileName)}',
        kind: isLink ? _FileKind.link : _kindOf(state.fileName),
        actionLabel: 'Change',
        onAction: goBack,
      ),
      const SizedBox(height: AppSpacing.md),
      _SectionCard(
        children: [
          const _FieldLabel('Title *'),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'DBMS end-sem solved papers',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Your own subjects first; "More subjects" inside searches the rest
          SubjectPickerField(
            label: 'Subject *',
            subjects: state.subjects,
            selected: state.selectedSubject,
            isLoading: state.isLoadingSubjects,
            onSelected: _cubit.selectSubject,
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      _SectionCard(
        children: [
          const _FieldLabel('Category *'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final type in ResourceType.values)
                _TypeChip(
                  label: type.label,
                  icon: _iconOfType(type),
                  selected: type == state.type,
                  onTap: () => _cubit.selectType(type),
                ),
            ],
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      _SectionCard(
        children: [
          const _FieldLabel('Description', hint: '(optional)'),
          TextField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Exam year, unit covered, anything that helps others',
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: state.isSubmitting
            ? 'Uploading...'
            : (_savingLocally ? 'Saving...' : 'Upload and Save Document'),
        icon: Icons.cloud_upload_outlined,
        onPressed: busy ? null : _onSavePressed,
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Next you\'ll choose: upload online or save on this device.',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(fontSize: 12),
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// helpers

enum _FileKind { pdf, image, link }

_FileKind _kindOf(String? name) {
  final n = (name ?? '').toLowerCase();
  return n.endsWith('.pdf') ? _FileKind.pdf : _FileKind.image;
}

String _kindLabel(String? name) =>
    _kindOf(name) == _FileKind.pdf ? 'PDF' : 'Image';

String _formatSize(int bytes) {
  final mb = bytes / (1024 * 1024);
  if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
  return '${(bytes / 1024).ceil()} KB';
}

IconData _iconOfType(ResourceType type) => switch (type) {
  ResourceType.pyq => Icons.description_outlined,
  ResourceType.notes => Icons.sticky_note_2_outlined,
  ResourceType.syllabus => Icons.list_alt_outlined,
  ResourceType.book => Icons.menu_book_outlined,
  ResourceType.assignment => Icons.edit_outlined,
  ResourceType.labManual => Icons.science_outlined,
  ResourceType.other => Icons.more_horiz,
};

/// "1 Add file ---- 2 Details"
class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(
          number: 1,
          label: 'Add file',
          done: step > 1,
          active: step == 1,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: step > 1 ? AppColors.primary : AppColors.border,
          ),
        ),
        _StepDot(number: 2, label: 'Details', done: false, active: step == 2),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.done,
    required this.active,
  });

  final int number;
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final filled = done || active;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.success
                : (active ? AppColors.primary : AppColors.border),
          ),
          child: done
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: filled ? Colors.white : AppColors.textSecondary,
                  ),
                ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: AppTextStyles.bodySemiBold.copyWith(
            fontSize: 13,
            color: filled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share what helped you',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Notes, PYQs and syllabus can help your whole campus.',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const SizedBox(
            width: 104,
            height: 92,
            child: CustomPaint(painter: _DocStackPainter()),
          ),
        ],
      ),
    );
  }
}

/// Stack of documents with an upload arrow (the hero illustration).
class _DocStackPainter extends CustomPainter {
  const _DocStackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    void sheet(Rect r, Color color, double degrees, Offset pivot) {
      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(degrees * 3.1415926 / 180);
      canvas.translate(-pivot.dx, -pivot.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(9)),
        Paint()..color = color,
      );
      canvas.restore();
    }

    sheet(
      const Rect.fromLTWH(14, 14, 56, 70),
      const Color(0xFFBFD3FB),
      -9,
      const Offset(42, 49),
    );
    sheet(
      const Rect.fromLTWH(26, 8, 56, 70),
      const Color(0xFF93B4F7),
      6,
      const Offset(54, 43),
    );

    final front = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, 12, 58, 72),
      const Radius.circular(9),
    );
    canvas.drawRRect(front, Paint()..color = Colors.white);
    canvas.drawRRect(
      front,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    void line(double y, double w, Color c) => canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(32, y, w, 5),
        const Radius.circular(2.5),
      ),
      Paint()..color = c,
    );
    line(26, 30, const Color(0xFFBFD3FB));
    line(37, 38, AppColors.border);
    line(48, 34, AppColors.border);

    canvas.drawCircle(
      const Offset(80, 70),
      16,
      Paint()..color = AppColors.primary,
    );
    final arrow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(80, 78)
        ..lineTo(80, 63)
        ..moveTo(80, 63)
        ..lineTo(74, 69)
        ..moveTo(80, 63)
        ..lineTo(86, 69),
      arrow,
    );

    canvas.drawCircle(
      const Offset(92, 18),
      4,
      Paint()..color = AppColors.accentOrange,
    );
    canvas.drawCircle(
      const Offset(10, 64),
      3,
      Paint()..color = AppColors.accentTeal,
    );
  }

  @override
  bool shouldRepaint(covariant _DocStackPainter old) => false;
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5F9FF) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// The chosen file (or link) with a small action on the right.
class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.name,
    required this.detail,
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    this.highlighted = false,
  });

  final String name;
  final String detail;
  final _FileKind kind;
  final String actionLabel;
  final VoidCallback onAction;
  final bool highlighted; // green "ready" look on step 1

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (kind) {
      _FileKind.pdf => (Icons.picture_as_pdf_outlined, AppColors.error),
      _FileKind.image => (Icons.image_outlined, AppColors.accentPurple),
      _FileKind.link => (Icons.link, AppColors.accentOrange),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? const Color(0xFFBBF7D0) : AppColors.border,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: highlighted
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card + 2),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text.rich(
        TextSpan(
          text: text,
          style: AppTextStyles.bodySemiBold.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          children: [
            if (hint != null)
              TextSpan(
                text: ' $hint',
                style: AppTextStyles.caption.copyWith(fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
