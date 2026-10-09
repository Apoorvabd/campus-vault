import 'package:equatable/equatable.dart';

class PostAuthor extends Equatable {
  const PostAuthor({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.username,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String username;
  final String? avatarUrl;

  String get fullName => lastName == null || lastName!.isEmpty
      ? firstName
      : '$firstName $lastName';

  factory PostAuthor.fromJson(Map<String, dynamic> json) => PostAuthor(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String?,
        username: json['username'] as String,
        avatarUrl: (json['avatar'] as Map<String, dynamic>?)?['secureUrl'] as String?,
      );

  @override
  List<Object?> get props => [id, firstName, lastName, username, avatarUrl];
}

class Post extends Equatable {
  const Post({
    required this.id,
    required this.title,
    required this.content,
    this.coverImageUrl,
    required this.author,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final String content;
  final String? coverImageUrl;
  final PostAuthor author;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final bool isLiked;
  final bool isBookmarked;

  Post copyWith({
    int? likeCount,
    int? commentCount,
    int? bookmarkCount,
    bool? isLiked,
    bool? isBookmarked,
  }) =>
      Post(
        id: id,
        title: title,
        content: content,
        coverImageUrl: coverImageUrl,
        author: author,
        createdAt: createdAt,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        bookmarkCount: bookmarkCount ?? this.bookmarkCount,
        isLiked: isLiked ?? this.isLiked,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  factory Post.fromJson(Map<String, dynamic> json) {
    final counts = (json['_count'] as Map<String, dynamic>?) ?? const {};
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      coverImageUrl:
          (json['coverImage'] as Map<String, dynamic>?)?['secureUrl'] as String?,
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      likeCount: (counts['likes'] as num?)?.toInt() ?? 0,
      commentCount: (counts['comments'] as num?)?.toInt() ?? 0,
      bookmarkCount: (counts['bookmarks'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id, title, content, coverImageUrl, author, createdAt, likeCount,
        commentCount, bookmarkCount, isLiked, isBookmarked,
      ];
}

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.userFirstName,
    this.userLastName,
    required this.username,
  });

  final String id;
  final String content;
  final String userId;
  final DateTime createdAt;
  final String userFirstName;
  final String? userLastName;
  final String username;

  String get userName => userLastName == null || userLastName!.isEmpty
      ? userFirstName
      : '$userFirstName $userLastName';

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return Comment(
      id: json['id'] as String,
      content: json['content'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userFirstName: user['firstName'] as String,
      userLastName: user['lastName'] as String?,
      username: user['username'] as String,
    );
  }

  @override
  List<Object?> get props => [id, content, userId, createdAt, userFirstName, userLastName, username];
}
