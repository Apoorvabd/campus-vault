import '../models/app_update_info.dart';
import '../network/api_client.dart';
import '../network/api_guard.dart';

class AppUpdateRepository {
  AppUpdateRepository(this._api);

  final ApiClient _api;

  Future<AppUpdateInfo?> checkUpdate({
    String platform = 'android',
    int? currentVersionCode,
  }) =>
      guardApi(() async {
        final res = await _api.dio.get(
          '/app/update',
          queryParameters: {
            'platform': platform,
            'version_code': ?currentVersionCode,
          },
        );

        final data = res.data['data'];
        if (data == null) return null;
        return AppUpdateInfo.fromJson(data as Map<String, dynamic>);
      });
}
