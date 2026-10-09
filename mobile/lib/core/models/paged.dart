/// A page of results from a page-numbered endpoint (resources, bookmarks).
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  factory PageResult.fromJson(
    List<dynamic> items,
    Map<String, dynamic> meta,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PageResult(
      items: items.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      page: meta['page'] as int,
      totalPages: meta['totalPages'] as int,
      total: meta['total'] as int,
    );
  }
}

/// A page of results from a cursor endpoint (posts, comments).
class CursorResult<T> {
  const CursorResult({
    required this.items,
    required this.hasNextPage,
    required this.nextCursor,
  });

  final List<T> items;
  final bool hasNextPage;
  final String? nextCursor;

  factory CursorResult.fromJson(
    List<dynamic> items,
    Map<String, dynamic> meta,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return CursorResult(
      items: items.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      hasNextPage: meta['hasNextPage'] as bool,
      nextCursor: meta['nextCursor'] as String?,
    );
  }
}
