改造目标：将 `checkinboard_page.dart` 中本地 `checkinboards` 示例数据改为从后端 API 获取，沿用与排行榜一致的分层模式（API/DTO → Repository → UseCase → ViewModel → Page）。

接口设计
- URL：`GET /api/checkinboard/list`
- 返回：
  - 形如 `{"code":"A200","data": { items: [{ activity, totalCheckins, topUser: { name, country, streak, year, allTime }, rankings: [{ rank, user, streak, year, allTime }] }], total, currentPage, pageSize }}`

字段说明
- activity（string）：活动名称
- totalCheckins（int）：该活动总打卡次数
- topUser（object）：该活动的头号用户信息
  - name（string）
  - country（string，可选）
  - streak（int）
  - year（int）
  - allTime（int）
- rankings（array）：榜单列表（按 rank 升序）
  - rank（int）
  - user（string）
  - streak（int）
  - year（int）
  - allTime（int）

示例返回（Mock JSON）
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "items": [
      {
        "activity": "HIIT Pro",
        "totalCheckins": 320,
        "topUser": { "name": "John Doe", "country": "USA", "streak": 45, "year": 120, "allTime": 300 },
        "rankings": [
          { "rank": 1, "user": "John Doe", "streak": 45, "year": 120, "allTime": 300 },
          { "rank": 2, "user": "Alice",    "streak": 38, "year": 110, "allTime": 270 },
          { "rank": 3, "user": "Bob",      "streak": 30, "year": 100, "allTime": 240 }
        ]
      },
      {
        "activity": "Yoga Flex",
        "totalCheckins": 210,
        "topUser": { "name": "Emily", "country": "Germany", "streak": 50, "year": 130, "allTime": 320 },
        "rankings": [
          { "rank": 1, "user": "Emily",  "streak": 50, "year": 130, "allTime": 320 },
          { "rank": 2, "user": "Sophia", "streak": 40, "year": 120, "allTime": 290 },
          { "rank": 3, "user": "Liam",   "streak": 35, "year": 110, "allTime": 260 }
        ]
      },
      {
        "activity": "Endurance Marathon",
        "totalCheckins": 410,
        "topUser": { "name": "Mike", "country": "USA", "streak": 60, "year": 150, "allTime": 380 },
        "rankings": [
          { "rank": 1, "user": "Mike",  "streak": 60, "year": 150, "allTime": 380 },
          { "rank": 2, "user": "Anna",  "streak": 55, "year": 140, "allTime": 350 },
          { "rank": 3, "user": "Chris", "streak": 50, "year": 135, "allTime": 340 }
        ]
      }
    ],
    "total": 3,
    "currentPage": 1,
    "pageSize": 3
  }
}
```

后续实现建议
- 前端新增：`CheckinboardApi/Repository/UseCase/ViewModel`，页面从 ViewModel 加载真实数据
- 后端聚合层：在 `CheckinController` 下新增 `GET /checkinboard/list` 接口，返回上述结构（网关已去除 /api）


新增接口：获取某活动的打卡排行分页
- URL：`GET /api/checkinboard/rankings`
- 入参（Query）：
  - `activity`（string，与列表里的 activity 对应，和 `activityId` 二选一）
  - `activityId`（string，可选，若有活动ID则优先使用）
  - `page`（int，选填，默认 1）
  - `pageSize`（int，选填，默认 16）
- 返回：
  - 成功：`{"code":"A200","data": { items: [{ rank, user, streak, year, allTime }], total, currentPage, pageSize }}`

示例返回（Mock JSON）
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "items": [
      { "rank": 1, "user": "John Doe", "streak": 45, "year": 120, "allTime": 300 },
      { "rank": 2, "user": "Alice",    "streak": 38, "year": 110, "allTime": 270 },
      { "rank": 3, "user": "Bob",      "streak": 30, "year": 100, "allTime": 240 }
    ],
    "total": 128,
    "currentPage": 1,
    "pageSize": 16
  }
}
```
