# Home Page 改造计划

## 1. 需要从API获取的数据分析

### 1.1 滚动公告栏 (_SimplifiedAnnouncementCarousel)
**当前硬编码参数：**
- `icon`: IconData (图标)
- `title`: String (标题)
- `subtitle`: String (副标题)
- `color`: Color (颜色)
- `route`: String? (路由)

**需要API获取的参数：**
- `title`: String (标题)
- `subtitle`: String (副标题)
- `priority`: int (优先级，用于排序)

### 1.2 最近7天突出比赛结果 (_ChampionCard)
**当前硬编码参数：**
- `name`: String (用户名)
- `challenge`: String (挑战名称)
- `rank`: String (排名)
- `score`: String (分数)
- `avatar`: String (头像路径)
- `gradient`: List<Color> (渐变颜色)

**需要API获取的参数：**
- `userId`: String (用户ID)
- `username`: String (用户名)
- `challengeName`: String (挑战名称)
- `challengeId`: String (挑战ID)
- `rank`: int (排名)
- `score`: double (分数)
- `completedAt`: String (完成时间)

### 1.3 最近7天打卡积极用户 (_ActiveUserCard)
**当前硬编码参数：**
- `name`: String (用户名)
- `streak`: String (连续天数)
- `avatar`: String (头像路径)
- `gradient`: List<Color> (渐变颜色)

**需要API获取的参数：**
- `userId`: String (用户ID)
- `username`: String (用户名)
- `streakDays`: int (连续打卡天数)
- `lastCheckinDate`: String (最后打卡日期)
- `yearlyCheckins`: int (今年打卡天数)
- `latestActivityName`: String (最新活动名称)

## 2. API设计

### 2.1 接口定义

#### 2.1.1 公告栏接口
```dart
// GET /api/home/announcements
// 返回首页公告栏数据
```

#### 2.1.2 最近冠军接口
```dart
// GET /api/home/recent-champions
// 返回最近7天突出比赛结果
```

#### 2.1.3 活跃用户接口
```dart
// GET /api/home/active-users
// 返回最近7天打卡积极用户
```

### 2.2 请求参数
```json
// 所有接口都无需参数，直接调用
```

### 2.3 响应数据结构

#### 2.3.1 公告栏接口响应
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "announcements": [
      {
        "id": "string",
        "title": "🔥 连续打卡7天",
        "subtitle": "恭喜您保持了一周的运动习惯！",
        "priority": 1
      }
    ]
  }
}
```

#### 2.3.2 最近冠军接口响应
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "recentChampions": [
      {
        "userId": "string",
        "username": "string",
        "challengeName": "HIIT Challenge",
        "challengeId": "string",
        "rank": 1,
        "score": 98.5,
        "completedAt": "2024-01-15T10:30:00Z",
        "avatar": "string"
      }
    ]
  }
}
```

#### 2.3.3 活跃用户接口响应
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "activeUsers": [
      {
        "userId": "string",
        "username": "string",
        "streakDays": 7,
        "lastCheckinDate": "2024-01-15",
        "yearlyCheckins": 25,
        "latestActivityName": "HIIT Challenge",
        "avatar": "string"
      }
    ]
  }
}
```

## 3. 架构改造方案

### 3.1 文件结构
```
lib/
├── data/
│   ├── api/
│   │   ├── home_announcements_api.dart
│   │   ├── home_champions_api.dart
│   │   └── home_active_users_api.dart
│   ├── models/
│   │   ├── home_announcements_api_model.dart
│   │   ├── home_champions_api_model.dart
│   │   └── home_active_users_api_model.dart
│   └── repository/
│       ├── home_announcements_repository.dart
│       ├── home_champions_repository.dart
│       └── home_active_users_repository.dart
├── domain/
│   ├── entities/
│   │   ├── announcement.dart
│   │   ├── champion.dart
│   │   └── active_user.dart
│   ├── services/
│   │   ├── home_announcements_service.dart
│   │   ├── home_champions_service.dart
│   │   └── home_active_users_service.dart
│   └── usecases/
│       ├── get_home_announcements_usecase.dart
│       ├── get_home_champions_usecase.dart
│       └── get_home_active_users_usecase.dart
└── presentation/
    └── home/
        ├── home_page.dart (改造后)
        ├── home_viewmodel.dart (新增)
        └── widgets/
            ├── announcement_carousel.dart
            ├── champion_card.dart
            └── active_user_card.dart
```

### 3.2 核心实体设计

#### 3.2.1 Announcement Entity
```dart
class Announcement {
  final String id;
  final String title;
  final String subtitle;
  final int priority;

  Announcement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
  });

  // 业务方法 - 前端硬编码映射
  IconData get icon => _getDefaultIcon();
  Color get color => _getDefaultColor();
}
```

#### 3.2.3 Champion Entity
```dart
class Champion {
  final String userId;
  final String username;
  final String challengeName;
  final String challengeId;
  final int rank;
  final double score;
  final DateTime completedAt;
  final String avatar;

  Champion({
    required this.userId,
    required this.username,
    required this.challengeName,
    required this.challengeId,
    required this.rank,
    required this.score,
    required this.completedAt,
    required this.avatar,
  });

  // 业务方法
  String get rankText => '$rank';
  String get scoreText => score.toStringAsFixed(1);
}
```

#### 3.2.4 ActiveUser Entity
```dart
class ActiveUser {
  final String userId;
  final String username;
  final int streakDays;
  final DateTime lastCheckinDate;
  final int yearlyCheckins;
  final String latestActivityName;
  final String avatar;

  ActiveUser({
    required this.userId,
    required this.username,
    required this.streakDays,
    required this.lastCheckinDate,
    required this.yearlyCheckins,
    required this.latestActivityName,
    required this.avatar,
  });

  // 业务方法
  String get streakText => '$streakDays days';
}
```

### 3.3 ViewModel设计
```dart
class HomeViewModel extends ChangeNotifier {
  final GetHomeAnnouncementsUseCase getHomeAnnouncementsUseCase;
  final GetHomeChampionsUseCase getHomeChampionsUseCase;
  final GetHomeActiveUsersUseCase getHomeActiveUsersUseCase;

  List<Announcement>? announcements;
  List<Champion>? recentChampions;
  List<ActiveUser>? activeUsers;
  
  String? announcementsError;
  String? championsError;
  String? activeUsersError;
  
  bool isAnnouncementsLoading = false;
  bool isChampionsLoading = false;
  bool isActiveUsersLoading = false;

  HomeViewModel({
    required this.getHomeAnnouncementsUseCase,
    required this.getHomeChampionsUseCase,
    required this.getHomeActiveUsersUseCase,
  });

  Future<void> loadAnnouncements() async {
    isAnnouncementsLoading = true;
    notifyListeners();

    try {
      announcements = await getHomeAnnouncementsUseCase.execute();
      announcementsError = null;
    } catch (e) {
      announcementsError = e.toString();
      announcements = null;
    }

    isAnnouncementsLoading = false;
    notifyListeners();
  }

  Future<void> loadChampions() async {
    isChampionsLoading = true;
    notifyListeners();

    try {
      recentChampions = await getHomeChampionsUseCase.execute();
      championsError = null;
    } catch (e) {
      championsError = e.toString();
      recentChampions = null;
    }

    isChampionsLoading = false;
    notifyListeners();
  }

  Future<void> loadActiveUsers() async {
    isActiveUsersLoading = true;
    notifyListeners();

    try {
      activeUsers = await getHomeActiveUsersUseCase.execute();
      activeUsersError = null;
    } catch (e) {
      activeUsersError = e.toString();
      activeUsers = null;
    }

    isActiveUsersLoading = false;
    notifyListeners();
  }

  Future<void> loadAllData() async {
    // 并行加载所有数据
    await Future.wait([
      loadAnnouncements(),
      loadChampions(),
      loadActiveUsers(),
    ]);
  }

  // 计算属性
  bool get hasAnnouncements => announcements != null && announcements!.isNotEmpty;
  bool get hasChampions => recentChampions != null && recentChampions!.isNotEmpty;
  bool get hasActiveUsers => activeUsers != null && activeUsers!.isNotEmpty;
  
  List<Announcement> get sortedAnnouncements => 
    announcements?.toList()..sort((a, b) => a.priority.compareTo(b.priority)) ?? [];
    
  bool get hasAnyError => announcementsError != null || championsError != null || activeUsersError != null;
  bool get isAllLoading => isAnnouncementsLoading || isChampionsLoading || isActiveUsersLoading;
}
```

## 4. 改造步骤

### 4.1 第一步：创建数据层
1. 创建 `home_announcements_api_model.dart`
2. 创建 `home_champions_api_model.dart`
3. 创建 `home_active_users_api_model.dart`
4. 创建 `home_announcements_api.dart`
5. 创建 `home_champions_api.dart`
6. 创建 `home_active_users_api.dart`
7. 创建 `home_announcements_repository.dart`
8. 创建 `home_champions_repository.dart`
9. 创建 `home_active_users_repository.dart`

### 4.2 第二步：创建领域层
1. 创建实体类 (`announcement.dart`, `champion.dart`, `active_user.dart`)
2. 创建 `home_announcements_service.dart`
3. 创建 `home_champions_service.dart`
4. 创建 `home_active_users_service.dart`
5. 创建 `get_home_announcements_usecase.dart`
6. 创建 `get_home_champions_usecase.dart`
7. 创建 `get_home_active_users_usecase.dart`

### 4.3 第三步：创建表现层
1. 创建 `home_viewmodel.dart`
2. 改造 `home_page.dart` 使用MVVM架构
3. 提取可复用组件到widgets文件夹

### 4.4 第四步：集成测试
1. 测试各个独立API连接
2. 测试数据转换
3. 测试UI展示
4. 测试并行加载性能

## 5. 硬编码保留部分

以下部分保持硬编码，不需要API获取：
- 顶部欢迎区域的用户信息（从用户上下文获取）
- 使用说明部分
- 网站入口部分
- 社交媒体部分
- 所有UI样式和颜色配置

## 6. 注意事项

1. **错误处理**：API请求失败时显示友好的错误信息
2. **加载状态**：显示加载指示器
3. **缓存策略**：考虑添加本地缓存
4. **刷新机制**：支持下拉刷新
5. **空状态处理**：当没有数据时显示合适的空状态UI
6. **独立接口优势**：
   - 更好的性能：可以并行加载不同数据
   - 更好的错误隔离：一个接口失败不影响其他数据
   - 更好的缓存策略：可以针对不同数据类型设置不同的缓存策略
   - 更好的可维护性：每个接口职责单一
   - 更好的扩展性：可以独立扩展某个功能模块
