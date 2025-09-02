import 'playoff_match.dart';
import 'game_tracker_post.dart';
import 'preseason_record.dart';

// 挑战基础信息实体
class ChallengeBasic {
  final String challengeId;
  final String challengeName;
  final String backgroundImage;
  final String videoUrl;
  final String preseasonNotice;  // 新增：季前赛公告
  final ChallengeRules rules;
  final GameTrackerData gameTracker;

  ChallengeBasic({
    required this.challengeId,
    required this.challengeName,
    required this.backgroundImage,
    required this.videoUrl,
    required this.preseasonNotice,  // 新增
    required this.rules,
    required this.gameTracker,
  });
}

// 季后赛数据实体
class PlayoffData {
  final Map<String, String> stages;
  final Map<String, List<PlayoffMatch>> matches;

  PlayoffData({
    required this.stages,
    required this.matches,
  });
}

// 季前赛数据实体
class PreseasonData {
  final List<PreseasonRecord> records;
  final PaginationInfo pagination;  // 新增：分页信息

  PreseasonData({
    required this.records,
    required this.pagination,
  });
}

// 分页信息实体
class PaginationInfo {
  final int total;
  final int currentPage;
  final int pageSize;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });
}

// 游戏追踪数据实体
class GameTrackerData {
  final List<GameTrackerPost> posts;

  GameTrackerData({
    required this.posts,
  });
}

// 挑战规则实体
class ChallengeRules {
  final String title;
  final List<String> items;
  final String details;

  ChallengeRules({
    required this.title,
    required this.items,
    required this.details,
  });
} 