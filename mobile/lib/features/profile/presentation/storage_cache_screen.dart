import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../local_vault/bloc/local_vault_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

/// Storage & Cache — how much device space the vault uses, per category,
/// with a clear-cache action and two download preferences.
class StorageCacheScreen extends StatefulWidget {
  const StorageCacheScreen({super.key});

  @override
  State<StorageCacheScreen> createState() => _StorageCacheScreenState();
}

class _StorageCacheScreenState extends State<StorageCacheScreen> {
  static const _capacityMb = 2048;
  static const _downloadedMb = 98;

  int _cacheMb = 40;
  bool _wifiOnly = true;
  bool _autoClear = false;

  /// Real size of the files saved on this device (rounded up to whole MB).
  int get _localMb =>
      (context.read<LocalVaultCubit>().state.totalBytes / (1024 * 1024)).ceil();

  int get _totalMb => _localMb + _downloadedMb + _cacheMb;

  String _format(int mb) =>
      mb >= 1024 ? '${(mb / 1024).toStringAsFixed(2)} GB' : '$mb MB';

  Future<void> _confirmClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cache?'),
        content: Text(
          'This frees ${_format(_cacheMb)} of thumbnails and temporary files. '
          'Your saved and downloaded documents are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _cacheMb = 0);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      TextSpan(text: _format(_totalMb)),
                      TextSpan(
                        text: '  / 2.0 GB',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: _totalMb / _capacityMb,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${_format(_capacityMb - _totalMb)} free offline headroom',
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
                  label: 'Locally saved files',
                  size: _format(_localMb),
                ),
                const Divider(height: 1, color: AppColors.border),
                _UsageRow(
                  color: AppColors.accentPurple,
                  label: 'Downloaded PDFs',
                  size: _format(_downloadedMb),
                ),
                const Divider(height: 1, color: AppColors.border),
                _UsageRow(
                  color: AppColors.accentOrange,
                  label: 'Cache & thumbnails',
                  size: _format(_cacheMb),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _cacheMb == 0 ? null : _confirmClearCache,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(
              _cacheMb == 0
                  ? 'Cache is empty'
                  : 'Clear Cache (${_format(_cacheMb)})',
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
