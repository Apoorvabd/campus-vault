class AppUpdateInfo {
  const AppUpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.latestVersionName,
    required this.latestVersionCode,
    required this.minimumVersionCode,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.releaseNotesList,
    this.publishedAt,
  });

  final bool updateAvailable;
  final bool forceUpdate;
  final String latestVersionName;
  final int latestVersionCode;
  final int minimumVersionCode;
  final String downloadUrl;
  final String releaseNotes;
  final List<String> releaseNotesList;
  final DateTime? publishedAt;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      updateAvailable: json['updateAvailable'] as bool? ?? false,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      latestVersionName: (json['latestVersionName'] as String?) ?? '1.0.0',
      latestVersionCode: (json['latestVersionCode'] as num?)?.toInt() ?? 1,
      minimumVersionCode: (json['minimumVersionCode'] as num?)?.toInt() ?? 1,
      downloadUrl: (json['downloadUrl'] as String?) ?? '',
      releaseNotes: (json['releaseNotes'] as String?) ?? '',
      releaseNotesList: (json['releaseNotesList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
    );
  }
}

