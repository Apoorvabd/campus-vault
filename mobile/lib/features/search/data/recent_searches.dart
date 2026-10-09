import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the last few search terms on this device.
class RecentSearches {
  static const _key = 'recent_searches';
  static const _max = 5;

  Future<List<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? [];
    } catch (_) {
      return []; // storage problems should never break search
    }
  }

  /// Puts [term] first, removes older copies, keeps only the latest 5.
  Future<List<String>> add(String term) async {
    final list = await load();
    final updated = [
      term,
      ...list.where((t) => t.toLowerCase() != term.toLowerCase()),
    ].take(_max).toList();
    await _save(updated);
    return updated;
  }

  Future<void> clear() => _save([]);

  Future<void> _save(List<String> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, list);
    } catch (_) {}
  }
}
