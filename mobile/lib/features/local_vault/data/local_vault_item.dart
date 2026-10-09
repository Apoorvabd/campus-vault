import 'package:equatable/equatable.dart';
import '../../../core/models/resource.dart';

/// Metadata of one file the user copied into the on-device vault.
/// The file's bytes live in the app's private folder; this is only the
/// description of it, saved as JSON.
class LocalVaultItem extends Equatable {
  const LocalVaultItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.semester,
    required this.title,
    required this.type,
    required this.relativePath,
    required this.sizeBytes,
    required this.addedAt,
  });

  final String id;
  final String subjectId;
  final String subjectName; // kept here so the list works fully offline
  final int? semester;
  final String title;
  final ResourceType type;

  /// Path inside the app documents folder, e.g. `vault/SUBJECT_ID/FILE_ID.pdf`.
  /// Never the absolute path: that base folder can change between app updates.
  final String relativePath;
  final int sizeBytes;
  final DateTime addedAt;

  String get sizeLabel {
    final mb = sizeBytes / (1024 * 1024);
    return mb >= 1
        ? '${mb.toStringAsFixed(1)} MB'
        : '${(sizeBytes / 1024).ceil()} KB';
  }

  factory LocalVaultItem.fromJson(Map<String, dynamic> json) => LocalVaultItem(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    subjectName: json['subjectName'] as String,
    semester: json['semester'] as int?,
    title: json['title'] as String,
    type: ResourceType.fromApi(json['type'] as String),
    relativePath: json['relativePath'] as String,
    sizeBytes: json['sizeBytes'] as int,
    addedAt: DateTime.parse(json['addedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'semester': semester,
    'title': title,
    'type': type.apiValue,
    'relativePath': relativePath,
    'sizeBytes': sizeBytes,
    'addedAt': addedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, subjectId, title, relativePath, sizeBytes];
}
