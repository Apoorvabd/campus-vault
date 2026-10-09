import 'package:equatable/equatable.dart';

class ProfileStats extends Equatable {
  const ProfileStats({
    required this.posts,
    required this.approvedResources,
    required this.postLikes,
  });

  final int posts;
  final int approvedResources;
  final int postLikes;

  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
        posts: (json['posts'] as num).toInt(),
        approvedResources: (json['approvedResources'] as num).toInt(),
        postLikes: (json['postLikes'] as num).toInt(),
      );

  @override
  List<Object?> get props => [posts, approvedResources, postLikes];
}

/// The logged-in user's full profile (GET /profile/me).
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.username,
    this.email,
    this.bio,
    this.headline,
    this.role,
    this.isVerified = false,
    required this.currentSemester,
    this.subjectsSemester,
    this.subjectsConfirmedAt,
    this.avatarUrl,
    required this.universityId,
    required this.universityName,
    required this.universityShortName,
    required this.collegeId,
    required this.collegeName,
    this.collegeShortName,
    required this.courseId,
    required this.courseName,
    this.courseShortName,
    this.totalSemesters,
    this.stats,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String username;
  final String? email;
  final String? bio;
  final String? headline;
  final String? role; // STUDENT, UNIVERSITY_ADMIN, SUPER_ADMIN
  final bool isVerified;
  final int currentSemester;
  final int? subjectsSemester; // semester the saved subject picks are for
  final DateTime? subjectsConfirmedAt; // null = form never saved
  final String? avatarUrl;
  final String universityId;
  final String universityName;
  final String universityShortName;
  final String collegeId;
  final String collegeName;
  final String? collegeShortName;
  final String courseId;
  final String courseName;
  final String? courseShortName;
  final int? totalSemesters;
  final ProfileStats? stats; // missing in edit/avatar responses

  String get fullName => lastName == null || lastName!.isEmpty
      ? firstName
      : '$firstName $lastName';

  /// True until the user saves their subjects, and again after the semester
  /// changes (the old picks belong to the previous semester).
  bool get needsSubjectsSetup =>
      subjectsConfirmedAt == null || subjectsSemester != currentSemester;

  /// "Student", "Admin" ... for the profile header badge.
  String get roleLabel => switch (role) {
        'SUPER_ADMIN' => 'Super Admin',
        'UNIVERSITY_ADMIN' => 'Admin',
        _ => 'Student',
      };

  /// "Ramanujan College (DU)" style.
  String get collegeLabel => '$collegeName ($universityShortName)';

  /// Keeps the previous stats when a response does not carry them.
  Profile withStatsFrom(Profile? previous) => stats != null || previous == null
      ? this
      : Profile(
          id: id, firstName: firstName, lastName: lastName, username: username,
          email: email, bio: bio, headline: headline, role: role,
          isVerified: isVerified, currentSemester: currentSemester,
          subjectsSemester: subjectsSemester,
          subjectsConfirmedAt: subjectsConfirmedAt, avatarUrl: avatarUrl, universityId: universityId,
          universityName: universityName,
          universityShortName: universityShortName, collegeId: collegeId,
          collegeName: collegeName, collegeShortName: collegeShortName,
          courseId: courseId, courseName: courseName,
          courseShortName: courseShortName, totalSemesters: totalSemesters,
          stats: previous.stats,
        );

  factory Profile.fromJson(Map<String, dynamic> json) {
    final university = json['university'] as Map<String, dynamic>;
    final college = json['college'] as Map<String, dynamic>;
    final course = json['course'] as Map<String, dynamic>;
    final avatar = json['avatar'] as Map<String, dynamic>?;
    final stats = json['stats'] as Map<String, dynamic>?;
    return Profile(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      username: json['username'] as String,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      headline: json['headline'] as String?,
      role: json['role'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      currentSemester: (json['currentSemester'] as num).toInt(),
      subjectsSemester: (json['subjectsSemester'] as num?)?.toInt(),
      subjectsConfirmedAt: json['subjectsConfirmedAt'] == null
          ? null
          : DateTime.parse(json['subjectsConfirmedAt'] as String),
      avatarUrl: avatar?['secureUrl'] as String?,
      universityId: university['id'] as String,
      universityName: university['name'] as String,
      universityShortName: university['shortName'] as String,
      collegeId: college['id'] as String,
      collegeName: college['name'] as String,
      collegeShortName: college['shortName'] as String?,
      courseId: course['id'] as String,
      courseName: course['name'] as String,
      courseShortName: course['shortName'] as String?,
      totalSemesters: (course['totalSemesters'] as num?)?.toInt(),
      stats: stats == null ? null : ProfileStats.fromJson(stats),
    );
  }

  @override
  List<Object?> get props => [
        id, firstName, lastName, username, email, bio, headline, role,
        isVerified, currentSemester, subjectsSemester, subjectsConfirmedAt,
        avatarUrl, universityId, universityName,
        universityShortName, collegeId, collegeName, collegeShortName, courseId,
        courseName, courseShortName, totalSemesters, stats,
      ];
}
