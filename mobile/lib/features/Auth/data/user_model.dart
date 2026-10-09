import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.username,
    required this.email,
    required this.role,
    required this.canPost,
    required this.isVerified,
    required this.universityId,
    required this.collegeId,
    required this.courseId,
    required this.currentSemester,
  });

  final String id;
  final String firstName;
  final String? lastName; // nullable: the backend allows no last name
  final String username;
  final String email;
  final String role; // STUDENT, UNIVERSITY_ADMIN or SUPER_ADMIN
  final bool canPost;
  final bool isVerified;
  final String universityId;
  final String collegeId;
  final String courseId;
  final int currentSemester;

  // Handy for the UI: "Alex Sharma", or just "Alex" if there is no last name
  String get fullName => lastName == null || lastName!.isEmpty
      ? firstName
      : '$firstName $lastName';

  // Builds a UserModel from the JSON map the backend sends
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      canPost: json['canPost'] as bool,
      isVerified: json['isVerified'] as bool,
      universityId: json['universityId'] as String,
      collegeId: json['collegeId'] as String,
      courseId: json['courseId'] as String,
      currentSemester: json['currentSemester'] as int,
    );
  }

  // Equatable compares two UserModels by these fields.
  // Without this, Bloc couldn't tell whether a new state is really different.
  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    username,
    email,
    role,
    canPost,
    isVerified,
    universityId,
    collegeId,
    courseId,
    currentSemester,
  ];
}
