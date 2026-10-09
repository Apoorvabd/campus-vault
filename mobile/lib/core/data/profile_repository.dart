import 'package:dio/dio.dart';
import '../models/profile.dart';
import '../network/api_client.dart';
import '../network/api_guard.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  Future<Profile> getMe() => guardApi(() async {
        final res = await _api.dio.get('/profile/me');
        return Profile.fromJson(res.data['data']['profile']);
      });

  /// Only the fields you pass are changed. Pass an empty string to clear a
  /// text field that allows it (bio, headline, lastName).
  Future<Profile> update({
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    String? headline,
    int? currentSemester,
  }) =>
      guardApi(() async {
        final res = await _api.dio.patch('/profile/me', data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName.isEmpty ? null : lastName,
          if (username != null) 'username': username,
          if (bio != null) 'bio': bio.isEmpty ? null : bio,
          if (headline != null) 'headline': headline.isEmpty ? null : headline,
          if (currentSemester != null) 'currentSemester': currentSemester,
        });
        return Profile.fromJson(res.data['data']['profile']);
      });

  Future<Profile> uploadAvatar(String imagePath) => guardApi(() async {
        final form = FormData.fromMap({
          'avatar': await multipartFromPath(imagePath),
        });
        final res = await _api.dio.put('/profile/me/avatar', data: form);
        return Profile.fromJson(res.data['data']['profile']);
      });

  Future<Profile> removeAvatar() => guardApi(() async {
        final res = await _api.dio.delete('/profile/me/avatar');
        return Profile.fromJson(res.data['data']['profile']);
      });
}
