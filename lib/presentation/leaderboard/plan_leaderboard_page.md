改造目标：将 `leaderboard_page.dart` 中本地 `leaderboards` 示例数据改为从后端 API 获取，并采用与首页相同的分层模式（API/DTO → Repository → UseCase → ViewModel → Page）。

接口设计
- URL：`GET /api/challenge/leaderboard/list`
- 返回：
  - 形如 `{"code":"A200","data":[{ challengeId, activity, participants, topUser:{ name, counts }, rankings:[{ rank, userId, user, counts }] }]}`

示例返回（Mock JSON）
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "items": [
      {
        "challengeId": "pk1",
        "activity": "7-Day HIIT Showdown",
        "participants": 128,
        "topUser": { "name": "John Doe", "counts": 980 },
        "rankings": [
          { "rank": 1, "userId": "user_1", "user": "John Doe", "counts": 980 },
          { "rank": 2, "userId": "user_2", "user": "Alice", "counts": 950 },
          { "rank": 3, "userId": "user_3", "user": "Bob", "counts": 900 }
        ]
      },
      {
        "challengeId": "pk2",
        "activity": "Yoga Masters Cup",
        "participants": 89,
        "topUser": { "name": "Emily", "counts": 870 },
        "rankings": [
          { "rank": 1, "userId": "user_1", "user": "Emily", "counts": 870 },
          { "rank": 2, "userId": "user_2", "user": "Sophia", "counts": 860 },
          { "rank": 3, "userId": "user_3", "user": "Liam", "counts": 850 }
        ]
      },
      {
        "challengeId": "pk3",
        "activity": "Endurance Marathon",
        "participants": 256,
        "topUser": { "name": "Mike", "counts": 1200 },
        "rankings": [
          { "rank": 1, "userId": "user_1", "user": "Mike", "counts": 1200 },
          { "rank": 2, "userId": "user_2", "user": "Anna", "counts": 1150 },
          { "rank": 3, "userId": "user_3", "user": "Chris", "counts": 1100 }
        ]
      }
    ],
    "total": 3,
    "currentPage": 1,
    "pageSize": 3
  }
}
```

新增接口：获取某挑战的排行分页
- URL：`GET /api/challenge/leaderboard/rankings`
- 入参（Query）：
  - `challengeId`（string，必填）
  - `page`（int，选填，默认 1）
  - `pageSize`（int，选填，默认 16）
- 返回：
  - 成功：`{"code":"A200","data": { items: [{ rank, userId, user, counts }], total, currentPage, pageSize }}`

示例返回（Mock JSON）
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "items": [
      { "rank": 1,  "userId": "user_1",  "user": "John Doe",  "counts": 980 },
      { "rank": 2,  "userId": "user_2",  "user": "Alice",    "counts": 970 },
      { "rank": 3,  "userId": "user_3",  "user": "Bob",      "counts": 960 }
    ],
    "total": 128,
    "currentPage": 1,
    "pageSize": 16
  }
}
```

新增文件
- 数据层
  - `lib/data/api/leaderboard_api.dart`: 请求后端 `fetchLeaderboards()`
  - `lib/data/models/leaderboard_api_model.dart`: DTO 映射 `LeaderboardApiModel/TopUserApiModel/RankingItemApiModel`
  - `lib/data/repository/leaderboard_repository.dart`: `LeaderboardRepository` 与实现，将 DTO → 领域实体
- 领域层
  - `lib/domain/entities/leaderboard/leaderboard.dart`: `LeaderboardBoard/TopUser/RankingItem`
  - `lib/domain/usecases/get_leaderboards_usecase.dart`: 用例 `execute()`
- 表现层
  - `lib/presentation/leaderboard/leaderboard_viewmodel.dart`: 状态管理 `isLoading/error/boards`，`loadLeaderboards()`
  - 修改 `lib/presentation/leaderboard/leaderboard_page.dart`: 使用 `ChangeNotifierProvider` 注入 VM，渲染加载/错误/空/列表四态

页面改动要点（leaderboard_page.dart）
- 移除本地 `final List<Map<String,dynamic>> leaderboards`
- 引入 Provider：在 `build` 中创建 `LeaderboardViewModel`，并调用 `loadLeaderboards()`
- 使用 `Consumer` 获取 `viewModel.boards` 渲染；读取字段改为 `board.activity/participants/topUser.name/rankings[i].counts` 等
- 增加加载中、错误重试、空状态占位

一致性规范
- 计数字段统一用 `counts`（已在示例替换）
- 接口成功码沿用现有模式：HTTP 200 且 `code == 'A200'`

后续扩展
- 支持分页/筛选参数（活动类型、时间范围）
- 进入「完整排行榜」详情页路由与数据拉取

