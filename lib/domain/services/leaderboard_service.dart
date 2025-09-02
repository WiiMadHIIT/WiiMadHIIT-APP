import '../entities/leaderboard/leaderboard.dart';

/// Leaderboard 业务规则与便捷方法
class LeaderboardService {
  /// 取前 n 名，安全处理越界
  List<RankingItem> topN(List<RankingItem> all, int n) {
    if (n <= 0) return const [];
    if (all.length <= n) return List<RankingItem>.from(all);
    return all.sublist(0, n);
  }

  /// 根据 rank 升序排序（若已排序则返回拷贝）
  List<RankingItem> sortByRank(List<RankingItem> items) {
    final list = List<RankingItem>.from(items);
    list.sort((a, b) => a.rank.compareTo(b.rank));
    return list;
  }

  /// 过滤某个用户的记录（按 userId）
  List<RankingItem> filterByUserId(List<RankingItem> items, String userId) {
    return items.where((e) => e.userId == userId).toList();
  }

  /// 计算总页数
  int calculateTotalPages(int total, int pageSize) {
    if (pageSize <= 0) return 0;
    return (total / pageSize).ceil();
  }

  /// 检查是否有下一页
  bool hasNextPage(int currentPage, int totalPages) {
    return currentPage < totalPages;
  }

  /// 检查是否有上一页
  bool hasPreviousPage(int currentPage) {
    return currentPage > 1;
  }
}


