# Training List 页面 MVVM 架构改造计划

## 📋 当前状态分析

### 现有问题
- 所有业务逻辑都集中在 `training_list_page.dart` 中
- 数据是硬编码的，没有从后端获取
- 缺乏状态管理和错误处理
- 不符合 MVVM + Provider 架构规范
- 配置数据通过 `_getConfigByProductId` 方法硬编码

### 当前数据结构
```dart
class TrainingPageConfig {
  final String? videoUrl;           // 视频URL（可为空，回退到本地视频）
  final String? thumbnailUrl;       // 缩略图URL（可为空，回退到本地图片）
  final String pageTitle;           // 页面标题
  final String pageSubtitle;        // 页面副标题
  final List<PersonalTraining> trainings; // 训练列表
}

class PersonalTraining {
  final String id;           // 训练ID
  final String name;         // 训练名称
  final String level;        // 难度等级
  final String description;  // 描述
  final int participantCount; // 参与人数
  final double completionRate; // 完成率
}
```

## 🔄 需要从后端 API 获取的参数

### 1. 页面配置信息（必需）
- ✅ **`pageTitle`** - 页面标题（如："HIIT Pro Training"）
- ✅ **`pageSubtitle`** - 页面副标题（如："High-intensity interval training for maximum results"）
- ✅ **`videoUrl`** - 视频URL（可为空，支持本地回退）
- ✅ **`thumbnailUrl`** - 缩略图URL（可为空，支持本地回退）

### 2. 训练列表数据（必需）
- ✅ **`trainings`** - 训练项目列表数组

### 3. 单个训练项目信息（必需）
- ✅ **`id`** - 训练唯一标识符
- ✅ **`name`** - 训练名称
- ✅ **`level`** - 难度等级（Beginner, Intermediate, Advanced）
- ✅ **`description`** - 训练描述
- ✅ **`participantCount`** - 参与人数（显示训练热门程度）
- ✅ **`completionRate`** - 完成率（显示训练可完成性）

### 4. 建议新增的参数
- 🆔 **`productId`** - 产品ID（从路由参数获取）
- 🔄 **`status`** - 训练状态（可用/维护中/已下架）
- 📅 **`lastUpdated`** - 最后更新时间

### 5. 智能回退机制
- 🔄 **`displayVideoUrl`** - 获取器方法：优先网络视频，回退本地默认
- 🔄 **`displayThumbnailUrl`** - 获取器方法：优先网络图片，回退本地默认
- 🔄 **`hasCustomVideo`** - 判断是否使用网络视频
- 🔄 **`hasCustomThumbnail`** - 判断是否使用网络图片

## 📊 建议的 API 数据结构

### 主要接口：`GET /training/products/{productId}`

**注意**: `videoUrl` 和 `thumbnailUrl` 字段可以为 `null` 或空字符串：
- `null` 或空字符串：使用本地默认资源
- 有效URL：使用网络资源，失败时回退到本地默认

```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "productId": "hiit_pro_001",
    "pageConfig": {
      "pageTitle": "HIIT Pro Training",
      "pageSubtitle": "High-intensity interval training for maximum results",
      "videoUrl": "https://github.com/WiiMadHIIT/hiit-cdn/tree/main/video/video1.mp4",
      "thumbnailUrl": "https://cdn.example.com/thumbnails/hiit_pro.jpg",
      "lastUpdated": "2024-03-15T10:30:00Z"
    },
    "trainings": [
      {
        "id": "training_001",
        "name": "HIIT Beginner",
        "level": "Beginner",
        "description": "Perfect introduction to HIIT training",
        "participantCount": 1250,
        "completionRate": 85.5,
        "status": "ACTIVE"
      },
      {
        "id": "training_002",
        "name": "HIIT Intermediate",
        "level": "Intermediate",
        "description": "Classic Tabata protocol for maximum fat burn",
        "participantCount": 890,
        "completionRate": 78.2,
        "status": "ACTIVE"
      },
      {
        "id": "training_003",
        "name": "HIIT Advanced",
        "level": "Advanced",
        "description": "Pyramid intervals for elite athletes",
        "participantCount": 456,
        "completionRate": 65.8,
        "status": "ACTIVE"
      }
    ]
  }
}
```

### 空值处理示例

```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "productId": "default_001",
    "pageConfig": {
      "pageTitle": "Default Training",
      "pageSubtitle": "Choose your workout",
      "videoUrl": null,                    // 使用本地默认视频
      "thumbnailUrl": "",                  // 使用本地默认图片
      "lastUpdated": "2024-03-15T10:30:00Z"
    },
    "trainings": [
      {
        "id": "default_1",
        "name": "Default Training",
        "level": "Beginner",
        "description": "Default training session",
        "participantCount": 100,
        "completionRate": 80.0,
        "status": "ACTIVE"
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
      training_api.dart              // API 请求
    models/
      training_api_model.dart        // API 数据模型
    repository/
      training_repository.dart       // 数据仓库
  domain/
    entities/
      training_product.dart          // 产品配置实体
      training_item.dart             // 训练项目实体
    services/
      training_service.dart          // 业务服务
    usecases/
      get_training_product_usecase.dart    // 获取产品配置
      get_training_list_usecase.dart       // 获取训练列表
  presentation/
    checkin_start_training/
      training_list_page.dart        // View（UI）
      training_list_viewmodel.dart   // ViewModel（状态管理）
```

### 2. 各层职责

#### **Domain 层**
- **`training_product.dart`**: 产品配置业务实体，包含页面配置信息
- **`training_item.dart`**: 训练项目业务实体，包含训练详细信息
- **`training_service.dart`**: 复杂业务逻辑（如难度计算、推荐算法）
- **`get_training_product_usecase.dart`**: 获取产品配置的业务流程
- **`get_training_list_usecase.dart`**: 获取训练列表的业务流程

#### **Data 层**
- **`training_api.dart`**: 网络请求封装
- **`training_api_model.dart`**: API 响应数据结构
- **`training_repository.dart`**: 数据转换和缓存

#### **Presentation 层**
- **`training_list_page.dart`**: 纯 UI 展示，通过 Provider 监听状态
- **`training_list_viewmodel.dart`**: 状态管理，调用 UseCase

### 3. 改造步骤

#### **第一步：创建 Domain 层**
1. 创建 `training_product.dart` 业务实体
2. 创建 `training_item.dart` 业务实体
3. 创建 `training_service.dart` 业务服务
4. 创建 `get_training_product_usecase.dart`
5. 创建 `get_training_list_usecase.dart`

#### **第二步：创建 Data 层**
1. 创建 `training_api_model.dart` API 模型
2. 创建 `training_api.dart` API 请求
3. 创建 `training_repository.dart` 数据仓库

#### **第三步：创建 Presentation 层**
1. 创建 `training_list_viewmodel.dart` 状态管理
2. 重构 `training_list_page.dart` 为纯 UI 组件

#### **第四步：集成测试**
1. 测试数据流
2. 测试错误处理
3. 测试状态管理

## 🎯 UI 增强建议

### 当前显示内容
1. 页面标题和副标题
2. 视频背景
3. 训练项目列表（名称、等级、描述、参与人数、完成率）

### 建议增强显示
1. 🟢 训练状态指示器（可用/维护中）
2. 📊 完成率统计
3. 📅 最后更新时间

## 🔧 业务逻辑增强

### 1. 推荐算法
```dart
class TrainingService {
  List<TrainingItem> getRecommendedTrainings(List<TrainingItem> trainings, UserProfile user) {
    // 根据用户历史、偏好、等级推荐训练
  }
}
```

### 2. 训练统计
```dart
class TrainingService {
  TrainingStatistics getTrainingStatistics(List<TrainingItem> trainings) {
    // 计算训练统计信息
  }
}
```

## 📝 改造优先级

### 高优先级（立即改造）
1. ✅ 基础数据从 API 获取
2. ✅ 实现 MVVM 架构
3. ✅ 添加错误处理
4. ✅ 添加加载状态
5. ✅ 视频URL支持网络和本地回退
6. ✅ 空值处理和智能回退机制

### 中优先级（后续增强）
1. 🔄 训练状态管理
2. 🔄 推荐算法

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

**总结**: 通过 MVVM 架构改造，Training List 页面将具备更好的可维护性、可测试性和可扩展性，同时提供更丰富的用户体验和更准确的数据展示。

### 🎯 字段优化亮点
- **命名优化**: `videoPath` → `videoUrl`，`fallbackImagePath` → `thumbnailUrl`
- **空值支持**: 所有资源字段支持 `null` 值，提供灵活的配置选项
- **智能回退**: 网络资源失败时自动回退到本地默认资源
- **获取器方法**: 封装复杂的判断逻辑，提供清晰的API接口
