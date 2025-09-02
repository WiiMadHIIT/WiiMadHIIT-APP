import '../entities/checkinboard/checkinboard.dart';

/// Checkinboard 业务规则与便捷方法
class CheckinboardService {
  bool isPageDataValid(CheckinboardPage page) {
    return page.items.isNotEmpty && page.items.first.rankings.isNotEmpty;
  }

  List<CheckinRanking> top3(CheckinboardItem item) {
    final list = List<CheckinRanking>.from(item.rankings);
    list.sort((a, b) => a.rank.compareTo(b.rank));
    return list.length <= 3 ? list : list.sublist(0, 3);
  }

  List<CheckinRanking> sortByRank(List<CheckinRanking> rankings) {
    final sorted = List<CheckinRanking>.from(rankings);
    sorted.sort((a, b) => a.rank.compareTo(b.rank));
    return sorted;
  }
}
