import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Measures (and clears) what the app keeps on the phone, from the real
/// folders. The saved-files vault lives in `vault/` inside the documents
/// folder and is counted by the vault itself, so it is skipped here.
class DeviceStorage {
  static const _vaultFolder = 'vault';

  /// Temporary files, e.g. the copies Android makes of photos and files the
  /// user picks.
  static Future<int> cacheBytes() async => _size(await getTemporaryDirectory());

  /// App files other than the vault and the cache.
  static Future<int> appDataBytes() async {
    final documents = await getApplicationDocumentsDirectory();
    final support = await getApplicationSupportDirectory();
    return await _size(documents, skipTopFolder: _vaultFolder) +
        await _size(support);
  }

  static Future<void> clearCache() async {
    final cache = await getTemporaryDirectory();
    if (!await cache.exists()) return;
    await for (final entry in cache.list()) {
      try {
        await entry.delete(recursive: true);
      } catch (_) {
        // A file in use stays; the rest is still cleared
      }
    }
  }

  static Future<int> _size(Directory dir, {String? skipTopFolder}) async {
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entry in dir.list(recursive: true, followLinks: false)) {
      if (entry is! File) continue;
      if (skipTopFolder != null &&
          entry.path.startsWith('${dir.path}/$skipTopFolder/')) {
        continue;
      }
      try {
        total += await entry.length();
      } catch (_) {
        // The file vanished while counting
      }
    }
    return total;
  }
}
