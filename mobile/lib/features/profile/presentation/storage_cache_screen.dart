import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../local_vault/bloc/local_vault_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/device_storage.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';

/// Storage & Cache: how much space the app uses on this phone, from the real
/// folders: the files the user saved, temporary files, and the app's own data.
/// The two preferences are only switches for now; nothing reads them yet.
class StorageCacheScreen extends StatefulWidget {
  const StorageCacheScreen({super.key});

  @override
  State<StorageCacheScreen> createState() => _StorageCacheScreenState();
}

class _StorageCacheScreenState extends State<StorageCacheScreen> {
  static const _capacityBytes = 4 * 1024 * 1024 * 1024; // 4 GB

  // null until measured
  int? _cacheBytes;
  int? _appDataBytes;
  bool _wifiOnly = true;
  bool _autoClear = false;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  Future<void> _measure() async {
    final cache = await DeviceStorage.cacheBytes();
    final appData = await DeviceStorage.appDataBytes();
    if (!mounted) return;
    setState(() {
      _cacheBytes = cache;
      _appDataBytes = appData;
    });
  }

  String _size(int? bytes) => bytes == null ? '...' : formatBytes(bytes);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    Color? actionColor,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action, style: TextStyle(color: actionColor)),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  Future<void> _confirmClearCache() async {
    final confirmed = await _confirm(
      title: 'Clear cache?',
      message:
          'This frees ${_size(_cacheBytes)} of temporary files, such as copies '
          'of photos and files you picked. Your saved documents are not '
          'affected.',
      action: 'Clear',
    );
    if (!confirmed) return;
    await DeviceStorage.clearCache();
    await _measure();
    if (mounted) _showMessage('Cache cleared');
  }

  Future<void> _confirmClearAll(int fileCount, int fileBytes) async {
    final vault = context.read<LocalVaultCubit>();
    final files = fileCount == 1 ? '1 file' : '$fileCount files';
    final confirmed = await _confirm(
      title: 'Delete all saved files?',
      message:
          'This permanently deletes the $files (${formatBytes(fileBytes)}) you '
          'saved locally on this phone, and clears the cache. This cannot be '
          'undone.\n\nYour account, posts and bookmarks are not affected.',
      action: 'Delete everything',
      actionColor: AppColors.error,
    );
    if (!confirmed) return;
    await vault.clearAll();
    await DeviceStorage.clearCache();
    await _measure();
    if (mounted) _showMessage('Storage cleared');
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<LocalVaultCubit>().state;
    final localBytes = vault.totalBytes;
    final fileCount = vault.items.length;
    final totalBytes = localBytes + (_cacheBytes ?? 0) + (_appDataBytes ?? 0);
    final canClearAll = fileCount > 0 || (_cacheBytes ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Storage & Cache'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            elevated: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VAULT STORAGE USED', style: AppTextStyles.overline),
                const SizedBox(height: AppSpacing.xs),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.displayBold.copyWith(
                      color: AppColors.primary,
                    ),
                    children: [
                      TextSpan(text: formatBytes(totalBytes)),
                      TextSpan(
                        text: '  / 4.0 GB',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: (totalBytes / _capacityBytes).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.primaryLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${formatBytes((_capacityBytes - totalBytes).clamp(0, _capacityBytes))} free offline headroom',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('BREAKDOWN', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                _UsageRow(
                  color: AppColors.primary,
                  label: 'Locally saved files ($fileCount)',
                  size: formatBytes(localBytes),
                ),
                const Divider(height: 1, color: AppColors.border),
                _UsageRow(
                  color: AppColors.accentPurple,
                  label: 'App data & settings',
                  size: _size(_appDataBytes),
                ),
                const Divider(height: 1, color: AppColors.border),
                _UsageRow(
                  color: AppColors.accentOrange,
                  label: 'Cache & temporary files',
                  size: _size(_cacheBytes),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: (_cacheBytes ?? 0) == 0 ? null : _confirmClearCache,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(
              (_cacheBytes ?? 0) == 0
                  ? 'Cache is empty'
                  : 'Clear Cache (${_size(_cacheBytes)})',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('PREFERENCES', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: Text(
                    'Download over Wi-Fi only',
                    style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Save mobile data when fetching PDFs.',
                    style: AppTextStyles.caption,
                  ),
                  value: _wifiOnly,
                  onChanged: (value) => setState(() => _wifiOnly = value),
                ),
                const Divider(height: 1, color: AppColors.border),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: Text(
                    'Auto-clear cache every 30 days',
                    style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Never touches your saved documents.',
                    style: AppTextStyles.caption,
                  ),
                  value: _autoClear,
                  onChanged: (value) => setState(() => _autoClear = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text('Advanced', style: AppTextStyles.bodyMedium),
                  const Spacer(),
                  Icon(
                    _showAdvanced ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_showAdvanced)
            OutlinedButton.icon(
              onPressed: canClearAll
                  ? () => _confirmClearAll(fileCount, localBytes)
                  : null,
              icon: const Icon(Icons.warning_amber_rounded, size: 18),
              label: const Text('Clear all storage'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: canClearAll ? AppColors.error : AppColors.border,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.color,
    required this.label,
    required this.size,
  });

  final Color color;
  final String label;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
            ),
          ),
          Text(size, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
