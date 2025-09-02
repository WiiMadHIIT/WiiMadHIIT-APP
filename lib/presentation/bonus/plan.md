# Bonus 页面 MVVM 架构改造计划

## 📋 当前状态分析

### 现有问题
- 所有业务逻辑都集中在 `bonus_page.dart` 中
- 数据是硬编码的，没有从后端获取
- 缺乏状态管理和错误处理
- 不符合 MVVM + Provider 架构规范


## API 数据结构

```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "activities": [
      {
        "id": "bonus_001",
        "name": "Spring Challenge",
        "description": "Join the spring fitness challenge and win big!",
        "reward": "Up to 1000 WiiCoins + Exclusive Badge",
        "regionLimit": "US, Canada, UK",
        "videoUrl": "https://cdn.example.com/videos/bonus1.mp4",
        "startTimeStep": 1737367600000,
        "endTimeStep": 1737367800000,
        "activityName":"xxx",
        "activityDescription": "xxx",
        "activityCode": "xxxx",
        "activityUrl": "https://cdn.example.com/videos/bonus1.mp4"
      }
    ]
  }
}
```

## 🏗️ MVVM 架构改造计划

### 1. 目录结构
```
lib/
  data/
    api/
      bonus_api.dart              // API 请求
    models/
      bonus_api_model.dart        // API 数据模型
    repository/
      bonus_repository.dart       // 数据仓库
  domain/
    entities/
      bonus_activity.dart         // 业务实体
    services/
      bonus_service.dart          // 业务服务
    usecases/
      get_bonus_activities_usecase.dart    // 获取活动列表
      claim_bonus_usecase.dart             // 领取奖励
  presentation/
    bonus/
      bonus_page.dart             // View（UI）
      bonus_viewmodel.dart        // ViewModel（状态管理）
```

### 2. 各层职责

#### **Domain 层**
- **`bonus_activity.dart`**: 业务实体，包含业务规则
- **`bonus_service.dart`**: 复杂业务逻辑（如地区限制检查、资格验证）
- **`get_bonus_activities_usecase.dart`**: 获取活动列表的业务流程
- **`claim_bonus_usecase.dart`**: 领取奖励的业务流程

#### **Data 层**
- **`bonus_api.dart`**: 网络请求封装
- **`bonus_api_model.dart`**: API 响应数据结构
- **`bonus_repository.dart`**: 数据转换和缓存

#### **Presentation 层**
- **`bonus_page.dart`**: 纯 UI 展示，通过 Provider 监听状态
- **`bonus_viewmodel.dart`**: 状态管理，调用 UseCase

### 3. 改造步骤

#### **第一步：创建 Domain 层**
1. 创建 `bonus_activity.dart` 业务实体
2. 创建 `bonus_service.dart` 业务服务
3. 创建 `get_bonus_activities_usecase.dart`
4. 创建 `claim_bonus_usecase.dart`

#### **第二步：创建 Data 层**
1. 创建 `bonus_api_model.dart` API 模型
2. 创建 `bonus_api.dart` API 请求
3. 创建 `bonus_repository.dart` 数据仓库

#### **第三步：创建 Presentation 层**
1. 创建 `bonus_viewmodel.dart` 状态管理
2. 重构 `bonus_page.dart` 为纯 UI 组件

#### **第四步：集成测试**
1. 测试数据流
2. 测试错误处理
3. 测试状态管理

## 🎯 UI 增强建议

### 建议增强显示
1. 🟢 活动状态指示器（进行中/已结束）
2. ⏰ 倒计时（如果活动有时间限制）
3. 🎁 领取按钮状态（可领取/已领取/不符合条件）
4. 👥 参与人数统计
5. ⭐ 难度等级标识
6. 🏷️ 活动分类标签

## 🔧 业务逻辑增强

### 1. 地区限制检查
```dart
class BonusService {
  bool isEligibleForRegion(String userRegion, String activityRegion) {
    if (activityRegion == "Global") return true;
    return activityRegion.contains(userRegion);
  }
}
```

### 2. 用户资格验证
```dart
class BonusService {
  bool isUserEligible(BonusActivity activity, UserProfile user) {
    // 检查地区限制
    // 检查用户等级
    // 检查是否已领取
    // 检查活动是否进行中
  }
}
```

### 3. 领取奖励流程
```dart
class ClaimBonusUseCase {
  Future<ClaimResult> execute(String activityId) async {
    // 1. 验证用户资格
    // 2. 调用领取 API
    // 3. 更新本地状态
    // 4. 返回结果
  }
}
```

## 📝 改造优先级

### 高优先级（立即改造）
1. ✅ 基础数据从 API 获取
2. ✅ 实现 MVVM 架构
3. ✅ 添加错误处理
4. ✅ 添加加载状态

### 中优先级（后续增强）
1. 🔄 活动状态管理
2. 🔄 用户领取状态
3. 🔄 地区限制检查
4. 🔄 活动统计信息

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

**总结**: 通过 MVVM 架构改造，Bonus 页面将具备更好的可维护性、可测试性和可扩展性，同时提供更丰富的用户体验。
