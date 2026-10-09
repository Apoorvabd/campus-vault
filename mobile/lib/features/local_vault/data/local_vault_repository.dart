import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/resource.dart';
import '../../../core/models/subject.dart';
import 'local_vault_item.dart';

/// Keeps user-picked files on the device, linked to a subject.
///
///  - bytes    -> `vault/SUBJECT_ID/FILE_ID.ext` in the app documents folder
///  - metadata -> SharedPreferences, one JSON list under [_key]
///
/// Nothing here touches the backend: it works fully offline.
class LocalVaultRepository {
  LocalVaultRepository(this._prefs);

  static const _key = 'local_vault_items';

  final SharedPreferences _prefs;

  Future<Directory> get _root => getApplicationDocumentsDirectory();

  List<LocalVaultItem> _read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => LocalVaultItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(List<LocalVaultItem> items) =>
      _prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));

  /// Newest first. Entries whose file has vanished (e.g. the user cleared the
  /// app's data from settings) are dropped so the list never shows dead items.
  Future<List<LocalVaultItem>> list() async {
    final items = _read();
    final alive = <LocalVaultItem>[];
    for (final item in items) {
      if (await (await fileFor(item)).exists()) alive.add(item);
    }
    if (alive.length != items.length) await _write(alive);
    alive.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return alive;
  }

  Future<File> fileFor(LocalVaultItem item) async =>
      File('${(await _root).path}/${item.relativePath}');

  /// Copies [sourcePath] into the vault and records it.
  /// The file is written first, the metadata second: if we crash in between
  /// we only have an unreferenced file, never an entry pointing at nothing.
  Future<LocalVaultItem> add({
    required String sourcePath,
    required String fileName,
    required String title,
    required ResourceType type,
    required Subject subject,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final dot = fileName.lastIndexOf('.');
    final ext = dot == -1 ? 'pdf' : fileName.substring(dot + 1).toLowerCase();
    final relativePath = 'vault/${subject.id}/$id.$ext';

    final dest = File('${(await _root).path}/$relativePath');
    await dest.parent.create(recursive: true);
    await File(sourcePath).copy(dest.path);

    final item = LocalVaultItem(
      id: id,
      subjectId: subject.id,
      subjectName: subject.name,
      semester: subject.semester,
      title: title,
      type: type,
      relativePath: relativePath,
      sizeBytes: await dest.length(),
      addedAt: DateTime.now(),
    );
    try {
      await _write([item, ..._read()]);
    } catch (_) {
      await dest.delete(); // don't leave an orphan file behind
      rethrow;
    }
    return item;
  }

  Future<void> delete(LocalVaultItem item) async {
    final file = await fileFor(item);
    if (await file.exists()) await file.delete();
    await _write(_read().where((e) => e.id != item.id).toList());
  }
}
