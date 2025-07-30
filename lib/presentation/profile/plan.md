# Profile 页面 MVVM 架构改造计划

## 📋 当前状态分析

### 现有问题
- 所有业务逻辑都集中在 `profile_page.dart` 中
- 数据是硬编码的，没有从后端获取
- 缺乏状态管理和错误处理
- 不符合 MVVM + Provider 架构规范

### 当前数据结构分析
从代码中可以看到以下硬编码的数据需要从后端获取：

## 🔄 需要从后端 API 获取的参数

### 1. 用户基础信息（必需）
- ✅ **`userId`** - 用户唯一标识符
- ✅ **`username`** - 用户昵称（当前硬编码为 'John Doe'）
- ✅ **`avatarUrl`** - 用户头像URL（当前使用默认头像）
- ✅ **`email`** - 用户邮箱

### 2. 用户统计数据（必需）
- ✅ **`currentStreak`** - 当前连续运动天数（当前硬编码为 '36 days'）
- ✅ **`daysThisYear`** - 今年运动天数（当前硬编码为 '120 days'）

### 3. 荣誉墙数据（必需）
- ✅ **`honors`** - 荣誉列表，包含：
  - `icon` - 荣誉图标
  - `label` - 荣誉标题（当前硬编码为 'Overall Champion', 'Best Streak'）
  - `description` - 荣誉描述（当前硬编码为 'HIIT Winner 2023', '60-Day Check-in Streak'）

### 4. 挑战记录数据（必需）
- ✅ **`challengeRecords`** - 挑战记录列表，包含：
  - `index` - 排名
  - `name` - 挑战名称（当前硬编码为 'HIIT 7-Day Challenge', 'Yoga Masters Cup'）
  - `rank` - 获得名次（当前硬编码为 '2nd', '1st'）

### 5. 打卡记录数据（必需）
- ✅ **`checkinRecords`** - 打卡记录列表，包含：
  - `index` - 序号
  - `name` - 训练名称（当前硬编码为 'HIIT Pro', 'Yoga Flex'）
  - `count` - 打卡次数（当前硬编码为 '36th Check-in', '20th Check-in'）

### 6. 建议新增的参数
- 📊 **`totalWorkouts`** - 总训练次数
- 📊 **`totalCalories`** - 总消耗卡路里
- 📊 **`totalDuration`** - 总训练时长
- 🏆 **`achievements`** - 成就列表
- 📈 **`weeklyStats`** - 周统计数据
- 📈 **`monthlyStats`** - 月统计数据
- 🎯 **`goals`** - 目标设置
- 👥 **`friends`** - 好友列表
- 🏅 **`level`** - 用户等级
- 💎 **`points`** - 积分

## 📊 建议的 API 数据结构

```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "user": {
      "userId": "user_123456789",
      "username": "John Doe",
      "email": "john.doe@example.com",
      "avatarUrl": "https://cdn.example.com/avatars/user_123.jpg",
      "level": 15,
      "points": 2500,
      "stats": {
        "currentStreak": 36,
        "daysThisYear": 120,
        "totalWorkouts": 450,
        "totalCalories": 125000,
        "totalDuration": 18000
      },
      "honors": [
        {
          "id": "honor_001",
          "icon": "emoji_events",
          "label": "Overall Champion",
          "description": "HIIT Winner 2023",
          "earnedAt": "2023-12-31T00:00:00Z"
        },
        {
          "id": "honor_002",
          "icon": "star",
          "label": "Best Streak",
          "description": "60-Day Check-in Streak",
          "earnedAt": "2023-11-15T00:00:00Z"
        }
      ],
      "challengeRecords": [
        {
          "id": "challenge_001",
          "index": 1,
          "name": "HIIT 7-Day Challenge",
          "rank": "2nd",
          "participatedAt": "2024-02-01T00:00:00Z"
        },
        {
          "id": "challenge_002",
          "index": 2,
          "name": "Yoga Masters Cup",
          "rank": "1st",
          "participatedAt": "2024-01-15T00:00:00Z"
        }
      ],
      "checkinRecords": [
        {
          "id": "checkin_001",
          "index": 1,
          "name": "HIIT Pro",
          "count": 36,
          "lastCheckinAt": "2024-03-01T00:00:00Z"
        },
        {
          "id": "checkin_002",
          "index": 2,
          "name": "Yoga Flex",
          "count": 20,
          "lastCheckinAt": "2024-02-28T00:00:00Z"
        }
      ]
    }
  }
}
```

## 🏗️ MVVM 架构改造计划

### 1. 目录结构
```
lib/
  data/
    api/
      profile_api.dart              // API 请求
    models/
      profile_api_model.dart        // API 数据模型
    repository/
      profile_repository.dart       // 数据仓库
  domain/
    entities/
      profile.dart                  // 业务实体
      user_stats.dart              // 用户统计实体
      honor.dart                   // 荣誉实体
      challenge_record.dart        // 挑战记录实体
      checkin_record.dart          // 打卡记录实体
    services/
      profile_service.dart         // 业务服务
    usecases/
      get_profile_usecase.dart     // 获取用户资料
      update_profile_usecase.dart  // 更新用户资料
  presentation/
    profile/
      profile_page.dart            // View（UI）
      profile_viewmodel.dart       // ViewModel（状态管理）
```

### 2. 各层职责

#### **Domain 层**
- **`profile.dart`**: 用户资料业务实体
- **`user_stats.dart`**: 用户统计业务实体
- **`honor.dart`**: 荣誉业务实体
- **`challenge_record.dart`**: 挑战记录业务实体
- **`checkin_record.dart`**: 打卡记录业务实体
- **`profile_service.dart`**: 复杂业务逻辑（如统计计算、成就解锁）
- **`get_profile_usecase.dart`**: 获取用户资料的业务流程
- **`update_profile_usecase.dart`**: 更新用户资料的业务流程

#### **Data 层**
- **`profile_api.dart`**: 网络请求封装
- **`profile_api_model.dart`**: API 响应数据结构
- **`profile_repository.dart`**: 数据转换和缓存

#### **Presentation 层**
- **`profile_page.dart`**: 纯 UI 展示，通过 Provider 监听状态
- **`profile_viewmodel.dart`**: 状态管理，调用 UseCase

### 3. 改造步骤

#### **第一步：创建 Domain 层**
1. 创建业务实体类
2. 创建 `profile_service.dart` 业务服务
3. 创建 UseCase 类

#### **第二步：创建 Data 层**
1. 创建 `profile_api_model.dart` API 模型
2. 创建 `profile_api.dart` API 请求
3. 创建 `profile_repository.dart` 数据仓库

#### **第三步：创建 Presentation 层**
1. 创建 `profile_viewmodel.dart` 状态管理
2. 重构 `profile_page.dart` 为纯 UI 组件

#### **第四步：集成测试**
1. 测试数据流
2. 测试错误处理
3. 测试状态管理

## 🎯 UI 增强建议

### 当前显示内容
1. 用户头像、昵称、ID
2. 运动天数统计
3. 荣誉墙
4. 挑战记录列表
5. 打卡记录列表

### 建议增强显示
1. 🏆 用户等级和积分
2. 📊 详细统计数据（总训练次数、卡路里、时长）
3. 🎯 目标进度条
4. 📈 周/月统计图表
5. 👥 好友列表
6. 🏅 成就徽章
7. 📱 设置入口

## 🔧 业务逻辑增强

### 1. 统计计算
```dart
class ProfileService {
  UserStats calculateStats(List<CheckinRecord> records) {
    // 计算总训练次数、卡路里、时长等
  }
}
```

### 2. 成就解锁
```dart
class ProfileService {
  List<Honor> checkAchievements(UserStats stats) {
    // 检查是否解锁新成就
  }
}
```

### 3. 等级计算
```dart
class ProfileService {
  int calculateLevel(int points) {
    // 根据积分计算用户等级
  }
}
```

## 📝 改造优先级

### 高优先级（立即改造）
1. ✅ 基础用户信息从 API 获取
2. ✅ 统计数据从 API 获取
3. ✅ 实现 MVVM 架构
4. ✅ 添加错误处理

### 中优先级（后续增强）
1. 🔄 荣誉系统
2. 🔄 挑战记录管理
3. 🔄 打卡记录管理
4. 🔄 等级积分系统

### 低优先级（优化体验）
1. 🎨 UI 增强显示
2. 🎨 动画效果优化
3. 🎨 缓存机制
4. 🎨 离线支持

## 🧪 测试计划

### 单元测试
- Domain 层业务逻辑测试
- Repository 层数据转换测试
- ViewModel 层状态管理测试

### 集成测试
- 完整数据流测试
- API 调用测试
- 错误处理测试

### UI 测试
- 页面渲染测试
- 用户交互测试
- 状态变化测试

---

**总结**: 通过 MVVM 架构改造，Profile 页面将具备更好的可维护性、可测试性和可扩展性，同时提供更丰富的用户统计和成就系统功能。