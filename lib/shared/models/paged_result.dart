/// Generic paginated response wrapper. Mirrors backend's PagedResult`<T>`.
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNext => page < totalPages;

  factory PagedResult.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PagedResult(
      items: (json['items'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}