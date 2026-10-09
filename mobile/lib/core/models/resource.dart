import 'package:equatable/equatable.dart';
import 'subject.dart';

/// Resource kinds, matching the backend enum.
enum ResourceType {
  pyq('PYQ', 'PYQ'),
  notes('NOTES', 'Notes'),
  syllabus('SYLLABUS', 'Syllabus'),
  book('BOOK', 'Reference Book'),
  assignment('ASSIGNMENT', 'Assignment'),
  labManual('LAB_MANUAL', 'Lab Manual'),
  other('OTHER', 'Other');

  const ResourceType(this.apiValue, this.label);

  final String apiValue; // what the backend sends and expects
  final String label; // what the user sees

  static ResourceType fromApi(String value) => ResourceType.values.firstWhere(
        (t) => t.apiValue == value,
        orElse: () => ResourceType.other,
      );
}

enum ResourceStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  const ResourceStatus(this.apiValue);

  final String apiValue;

  static ResourceStatus fromApi(String value) => ResourceStatus.values
      .firstWhere((s) => s.apiValue == value, orElse: () => pending);
}

/// Where the file lives: uploaded to our storage, an outside link, or no file.
enum ResourceSource {
  hosted('HOSTED'),
  externalLink('EXTERNAL_LINK'),
  referenceOnly('REFERENCE_ONLY');

  const ResourceSource(this.apiValue);

  final String apiValue;

  static ResourceSource fromApi(String value) => ResourceSource.values
      .firstWhere((s) => s.apiValue == value, orElse: () => referenceOnly);
}

class UploadedFile extends Equatable {
  const UploadedFile({
    required this.secureUrl,
    required this.originalName,
    required this.mimeType,
    required this.size,
  });

  final String secureUrl;
  final String originalName;
  final String mimeType;
  final int size; // bytes

  factory UploadedFile.fromJson(Map<String, dynamic> json) => UploadedFile(
        secureUrl: json['secureUrl'] as String,
        originalName: json['originalName'] as String? ?? 'file',
        mimeType: json['mimeType'] as String? ?? '',
        size: (json['size'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [secureUrl, originalName, mimeType, size];
}

class Uploader extends Equatable {
  const Uploader({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.username,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String username;

  /// "Rohit M." style: first name + last initial.
  String get shortName => lastName == null || lastName!.isEmpty
      ? firstName
      : '$firstName ${lastName![0]}.';

  factory Uploader.fromJson(Map<String, dynamic> json) => Uploader(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String?,
        username: json['username'] as String,
      );

  @override
  List<Object?> get props => [id, firstName, lastName, username];
}

class Resource extends Equatable {
  const Resource({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    this.rejectionReason,
    required this.downloadCount,
    required this.source,
    this.externalUrl,
    required this.subjectId,
    required this.createdAt,
    this.upload,
    this.subject,
    this.uploadedBy,
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final String? description;
  final ResourceType type;
  final ResourceStatus status;
  final String? rejectionReason;
  final int downloadCount;
  final ResourceSource source;
  final String? externalUrl;
  final String subjectId;
  final DateTime createdAt;
  final UploadedFile? upload;
  final Subject? subject;
  final Uploader? uploadedBy;
  final bool isBookmarked;

  /// The link to open: our hosted file, else the external link, else nothing.
  String? get fileUrl => upload?.secureUrl ?? externalUrl;

  bool get isPdf =>
      upload?.mimeType == 'application/pdf' ||
      (fileUrl?.toLowerCase().contains('.pdf') ?? false);

  String get uploaderName => uploadedBy?.shortName ?? 'Unknown';

  /// "4.2 MB" for hosted files, "External link" / "Reference" otherwise.
  String get sizeLabel {
    final file = upload;
    if (file == null) {
      return source == ResourceSource.externalLink ? 'External link' : 'Reference';
    }
    final mb = file.size / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${(file.size / 1024).ceil()} KB';
  }

  Resource copyWith({bool? isBookmarked, int? downloadCount}) => Resource(
        id: id,
        title: title,
        description: description,
        type: type,
        status: status,
        rejectionReason: rejectionReason,
        downloadCount: downloadCount ?? this.downloadCount,
        source: source,
        externalUrl: externalUrl,
        subjectId: subjectId,
        createdAt: createdAt,
        upload: upload,
        subject: subject,
        uploadedBy: uploadedBy,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        type: ResourceType.fromApi(json['resourceType'] as String),
        status: ResourceStatus.fromApi(json['status'] as String),
        rejectionReason: json['rejectionReason'] as String?,
        downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
        source: ResourceSource.fromApi(json['sourceType'] as String),
        externalUrl: json['externalUrl'] as String?,
        subjectId: json['subjectId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        upload: json['upload'] == null
            ? null
            : UploadedFile.fromJson(json['upload'] as Map<String, dynamic>),
        subject: json['subject'] == null
            ? null
            : Subject.fromJson(json['subject'] as Map<String, dynamic>),
        uploadedBy: json['uploadedBy'] == null
            ? null
            : Uploader.fromJson(json['uploadedBy'] as Map<String, dynamic>),
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id, title, description, type, status, rejectionReason, downloadCount,
        source, externalUrl, subjectId, createdAt, upload, subject, uploadedBy,
        isBookmarked,
      ];
}
