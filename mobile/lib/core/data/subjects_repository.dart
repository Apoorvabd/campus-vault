import '../models/subject.dart';
import '../models/subjects_form.dart';
import '../network/api_client.dart';
import '../network/api_guard.dart';

class SubjectsRepository {
  SubjectsRepository(this._api);

  final ApiClient _api;

  /// Subjects of a course, optionally only one semester.
  Future<List<Subject>> list({required String courseId, int? semester}) =>
      guardApi(() async {
        final res = await _api.dio.get('/subjects', queryParameters: {
          'courseId': courseId,
          if (semester != null) 'semester': semester,
        });
        final items = res.data['data']['subjects'] as List;
        return items
            .map((e) => Subject.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  /// The logged-in user's own subjects (their picks, or the semester default).
  Future<List<Subject>> mine() => guardApi(() async {
        final res = await _api.dio.get('/subjects/mine');
        final items = res.data['data']['subjects'] as List;
        return items
            .map((e) => Subject.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  /// Free-text subject search across the user's university (min 4 characters,
  /// enforced by the server too).
  Future<List<Subject>> search(String query) => guardApi(() async {
        final res = await _api.dio
            .get('/subjects/search', queryParameters: {'q': query});
        final items = res.data['data']['subjects'] as List;
        return items
            .map((e) => Subject.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<SubjectsForm> form() => guardApi(() async {
        final res = await _api.dio.get('/subjects/form');
        return SubjectsForm.fromJson(res.data['data'] as Map<String, dynamic>);
      });

  /// Saves the whole selection at once; the server replaces the old one.
  Future<void> saveMine({
    required List<String> dsc,
    String? ge,
    required List<String> dse,
    String? sec,
    String? vac,
    String? aec,
  }) =>
      guardApi(() async {
        await _api.dio.put('/subjects/mine', data: {
          'dsc': dsc,
          'ge': ge,
          'dse': dse,
          'sec': sec,
          'vac': vac,
          'aec': aec,
        });
      });
}
