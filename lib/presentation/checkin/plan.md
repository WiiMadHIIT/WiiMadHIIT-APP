# Checkin 页面 MVVM 架构改造计划

## 📋 当前状态分析

### 现有问题
- 所有业务逻辑都集中在 `checkin_page.dart` 中
- 数据是硬编码的，没有从后端获取
- 缺乏状态管理和错误处理
- 不符合 MVVM + Provider 架构规范

### 当前 ProductCheckin 数据结构
```dart
class ProductCheckin {
  final String id;           // 产品ID
  final String name;         // 产品名称
  final String description;  // 产品描述
  final String? iconUrl;     // 图标URL（可选，使用随机图标）
  final String? videoUrl;    // 视频URL（支持网络视频，失败时回退本地）
  
  // 计算属性
  String get routeName => "/training_list";  // 固定路由
  String get randomIcon => ...;              // 随机图标
}
```

## 🔄 需要从后端 API 获取的参数

### Checkin页面（第一次获取 - 简化版）
#### 1. 基础信息（必需）
- ✅ **`id`** - 产品唯一标识符
- ✅ **`name`** - 产品名称
- ✅ **`description`** - 产品描述

#### 2. 媒体资源（统一结构）
- ✅ **`iconUrl`** - 图标URL（可选，null表示使用随机图标，空字符串表示无图标）
- ✅ **`videoUrl`** - 视频URL（可选，null表示使用本地默认视频，空字符串表示无视频）

#### 3. 可选参数
- ❌ **`status`** - 产品状态（已移除，简化设计）

### Training List页面（第二次获取 - 详细版）
#### 1. 扩展信息
- 📅 **`createdAt`** - 创建时间
- 📅 **`updatedAt`** - 更新时间
- 🏷️ **`category`** - 产品分类（HIIT/Yoga/Strength/Cardio等）
- ⭐ **`difficulty`** - 难度等级（Beginner/Intermediate/Advanced）
- ⏱️ **`duration`** - 训练时长（分钟）
- 🔥 **`calories`** - 预估消耗卡路里
- 👥 **`popularity`** - 受欢迎程度（参与人数）
- 🎯 **`targetMuscles`** - 目标肌群
- 📊 **`completionRate`** - 完成率
- 🏆 **`rating`** - 用户评分
- 📝 **`tags`** - 标签数组
- 🖼️ **`thumbnailUrl`** - 缩略图URL（可选）
- 📱 **`isAvailable`** - 是否可用
- 🆕 **`isNew`** - 是否新品
- 🔥 **`isHot`** - 是否热门
- 🔄 **`iconUrl`** - 图标URL（可选，替代随机图标）

## 📊 API 设计策略

### 策略：分两次获取
- **第一次**: Checkin页面获取简化数据（卡片显示）
- **第二次**: Training List页面获取详细数据（详情显示）

### 第一次：Checkin页面 API（简化版）
**接口**: `GET /checkin/products`

```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "products": [
      {
        "id": "hiit_pro_001",
        "name": "HIIT Pro",
        "description": "High-Intensity Interval Training for maximum results",
        "iconUrl": "https://cdn.example.com/icons/hiit.svg",
        "videoUrl": "https://github.com/WiiMadHIIT/hiit-cdn/tree/main/video/video1.mp4"
      },
      {
        "id": "yoga_flex_002",
        "name": "Yoga Flex",
        "description": "Daily Yoga Flexibility and Mindfulness",
        "iconUrl": null,
        "videoUrl": "https://github.com/WiiMadHIIT/hiit-cdn/tree/main/video/video2.mp4"
      },
      {
        "id": "strength_003",
        "name": "Strength Training",
        "description": "Build muscle and increase strength",
        "iconUrl": "",
        "videoUrl": null
      }
    ]
  }
}
```

### 第二次：Training List页面 API（详细版）
**接口**: `GET /training/products/{productId}`

```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "product": {
      "id": "hiit_pro_001",
      "name": "HIIT Pro",
      "description": "High-Intensity Interval Training for maximum results",
      "iconUrl": "https://cdn.example.com/icons/hiit.svg",
      "videoUrl": "https://github.com/WiiMadHIIT/hiit-cdn/tree/main/video/video1.mp4",
      "thumbnailUrl": "https://cdn.example.com/thumbnails/hiit_pro.jpg",
      "status": "ACTIVE",
      "category": "HIIT",
      "difficulty": "INTERMEDIATE",
      "duration": 30,
      "calories": 450,
      "popularity": 12500,
      "targetMuscles": ["Core", "Legs", "Arms"],
      "completionRate": 0.85,
      "rating": 4.8,
      "tags": ["Cardio", "Strength", "Fat Burn"],
      "isAvailable": true,
      "isNew": false,
      "isHot": true,
      "createdAt": "2024-01-15T00:00:00Z",
      "updatedAt": "2024-03-01T00:00:00Z"
    }
  }
}
```

### 优势分析
- **性能优化**: Checkin页面加载更快，减少不必要的数据传输
- **按需加载**: 只在需要详细信息时才获取完整数据
- **网络友好**: 减少移动端流量消耗
- **用户体验**: 页面响应更快，交互更流畅

## 🔧 API 设计统一性原则

### 为什么需要统一的数据结构？

#### **1. 数据结构一致性**
- **所有产品都有相同的字段**: 避免前端需要处理不同的数据结构
- **统一的可选字段**: `iconUrl` 和 `videoUrl` 在所有产品中都存在
- **明确的空值语义**: `null` 和空字符串有明确的含义

#### **2. 前端处理简化**
```dart
// 统一的数据处理逻辑
class CheckinProduct {
  final String? iconUrl;
  final String? videoUrl;
  
  // 智能显示逻辑
  String get displayIcon {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return randomIcon;  // 使用随机图标
    }
    return iconUrl!;      // 使用API图标
  }
  
  String get displayVideo {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return "assets/video/video1.mp4";  // 使用本地默认视频
    }
    return videoUrl!;     // 使用API视频
  }
}
```

#### **3. 空值语义定义**
- **`iconUrl: null`**: 使用随机图标
- **`iconUrl: ""`**: 不显示图标
- **`videoUrl: null`**: 使用本地默认视频
- **`videoUrl: ""`**: 不显示视频

#### **4. 后端实现灵活性**
```json
// 示例1：完整资源
{
  "id": "hiit_pro_001",
  "name": "HIIT Pro",
  "description": "High-Intensity Interval Training",
  "iconUrl": "https://cdn.example.com/icons/hiit.svg",
  "videoUrl": "https://cdn.example.com/videos/hiit.mp4"
}

// 示例2：部分资源
{
  "id": "yoga_flex_002",
  "name": "Yoga Flex",
  "description": "Daily Yoga Flexibility",
  "iconUrl": null,  // 使用随机图标
  "videoUrl": "https://cdn.example.com/videos/yoga.mp4"
}

// 示例3：最小资源
{
  "id": "strength_003",
  "name": "Strength Training",
  "description": "Build muscle and strength",
  "iconUrl": null,  // 使用随机图标
  "videoUrl": null  // 使用本地默认视频
}
```

#### **5. 维护性优势**
- **API版本兼容**: 新增字段不会破坏现有客户端
- **渐进式增强**: 可以逐步为产品添加资源
- **错误处理简化**: 统一的空值处理逻辑
- **测试覆盖**: 统一的数据结构便于测试

## 🏛️ 架构设计原则

### 为什么使用不同的 Domain Entities？

#### **1. 单一职责原则 (SRP)**
- **`CheckinProduct`**: 专注于Checkin页面的展示逻辑
- **`TrainingProduct`**: 专注于Training页面的业务逻辑

#### **2. 领域驱动设计 (DDD)**
- **不同的业务上下文**: Checkin和Training是两个不同的业务场景
- **不同的业务规则**: 每个实体包含其特定场景的业务规则
- **不同的数据需求**: 简化版 vs 详细版的数据结构

#### **3. 数据隔离**
```dart
// CheckinProduct - 简化版
class CheckinProduct {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;    // 可选，null表示使用随机图标
  final String? videoUrl;   // 可选，null表示使用本地默认视频
  
  // 业务规则：智能图标选择、固定路由
  String get routeName => "/training_list";
  String get displayIcon => iconUrl ?? randomIcon;  // 优先使用API图标，否则随机
  String get randomIcon => ...;                     // 随机图标逻辑
}

// TrainingProduct - 详细版
class TrainingProduct {
  final String id;
  final String name;
  final String description;
  final String? videoUrl;
  final String? iconUrl;
  final String category;
  final String difficulty;
  final int duration;
  final int calories;
  final double rating;
  // ... 更多详细字段
  
  // 业务规则：难度计算、评分处理等
  bool get isAdvanced => difficulty == "ADVANCED";
  String get difficultyDisplay => ...;
}
```

#### **4. 维护性优势**
- **独立演进**: 两个实体可以独立修改和扩展
- **测试隔离**: 每个实体可以独立测试
- **依赖清晰**: 避免不必要的依赖关系
- **代码复用**: 通过接口或基类实现共享逻辑

#### **5. 性能考虑**
- **内存优化**: 只加载需要的数据
- **网络优化**: 减少数据传输量
- **渲染优化**: UI只处理必要的数据结构

## 🏗️ MVVM 架构改造计划

### 1. 目录结构
```
lib/
  data/
    api/
      checkin_api.dart                    // Checkin页面API请求
      training_api.dart                   // Training页面API请求
    models/
      checkin_api_model.dart              // Checkin页面API数据模型
      training_api_model.dart             // Training页面API数据模型
    repository/
      checkin_repository.dart             // Checkin页面数据仓库
      training_repository.dart            // Training页面数据仓库
  domain/
    entities/
      checkin_product.dart                // Checkin页面业务实体（简化版）
      training_product.dart               // Training页面业务实体（详细版）
    services/
      checkin_service.dart                // Checkin页面业务服务
      training_service.dart               // Training页面业务服务
    usecases/
      get_checkin_products_usecase.dart   // 获取Checkin产品列表
      get_training_product_usecase.dart   // 获取Training产品详情
  presentation/
    checkin/
      checkin_page.dart                   // Checkin页面View
      checkin_viewmodel.dart              // Checkin页面ViewModel
    training/
      training_list_page.dart             // Training页面View
      training_viewmodel.dart             // Training页面ViewModel
```

### 2. 各层职责

#### **Domain 层**
- **`checkin_product.dart`**: Checkin页面业务实体（简化版），包含基础业务规则
- **`training_product.dart`**: Training页面业务实体（详细版），包含完整业务规则
- **`checkin_service.dart`**: Checkin页面业务逻辑（如产品推荐、状态管理）
- **`training_service.dart`**: Training页面业务逻辑（如难度计算、评分处理）
- **`get_checkin_products_usecase.dart`**: 获取Checkin产品列表的业务流程
- **`get_training_product_usecase.dart`**: 获取Training产品详情的业务流程

#### **Data 层**
- **`checkin_api.dart`**: Checkin页面网络请求封装
- **`training_api.dart`**: Training页面网络请求封装
- **`checkin_api_model.dart`**: Checkin页面API响应数据结构
- **`training_api_model.dart`**: Training页面API响应数据结构
- **`checkin_repository.dart`**: Checkin页面数据转换和缓存
- **`training_repository.dart`**: Training页面数据转换和缓存

#### **Presentation 层**
- **`checkin_page.dart`**: Checkin页面UI展示，通过Provider监听状态
- **`checkin_viewmodel.dart`**: Checkin页面状态管理，调用UseCase
- **`training_list_page.dart`**: Training页面UI展示，通过Provider监听状态
- **`training_viewmodel.dart`**: Training页面状态管理，调用UseCase

### 3. 改造步骤

#### **第一阶段：Checkin页面改造**
1. 创建 `checkin_product.dart` 业务实体（简化版）
2. 创建 `checkin_service.dart` 业务服务
3. 创建 `get_checkin_products_usecase.dart`
4. 创建 `checkin_api_model.dart` API 模型
5. 创建 `checkin_api.dart` API 请求
6. 创建 `checkin_repository.dart` 数据仓库
7. 创建 `checkin_viewmodel.dart` 状态管理
8. 重构 `checkin_page.dart` 为纯 UI 组件

#### **第二阶段：Training页面改造**
1. 创建 `training_product.dart` 业务实体（详细版）
2. 创建 `training_service.dart` 业务服务
3. 创建 `get_training_product_usecase.dart`
4. 创建 `training_api_model.dart` API 模型
5. 创建 `training_api.dart` API 请求
6. 创建 `training_repository.dart` 数据仓库
7. 创建 `training_viewmodel.dart` 状态管理
8. 重构 `training_list_page.dart` 为纯 UI 组件

#### **第三阶段：集成测试**
1. 测试Checkin页面数据流
2. 测试Training页面数据流
3. 测试页面间数据传递
4. 测试错误处理
5. 测试状态管理

## 🎯 UI 显示策略

### 当前卡片显示内容（简化设计）
1. ✅ **产品名称**（`name`）- 主要标题
2. ✅ **产品描述**（`description`）- 副标题
3. ✅ **随机图标**（`randomIcon`）- 运动相关图标
4. ✅ **视频背景**（`videoUrl`）- 全屏背景视频
5. ✅ **CHECK-IN 标签** - 固定标签
6. ✅ **Start Training 按钮** - 操作按钮

### 设计原则
- 🎯 **简洁明了**: 卡片信息精简，突出核心功能
- 🎨 **视觉层次**: 清晰的信息层级，易于理解
- 🚀 **快速操作**: 一键进入训练，减少用户思考
- 🎬 **沉浸体验**: 视频背景增强视觉吸引力

### 未来扩展显示（详情页面）
1. 🏷️ 产品分类标签
2. ⭐ 难度等级标识
3. ⏱️ 训练时长
4. 🔥 预估卡路里
5. 👥 参与人数
6. 🏆 用户评分
7. 🆕 新品标识
8. 🔥 热门标识
9. 📊 完成率进度条

## 🔧 业务逻辑增强

### 1. 产品推荐算法
```dart
class CheckinService {
  List<CheckinProduct> getRecommendedProducts(List<CheckinProduct> products, UserProfile user) {
    // 基于用户历史、偏好、难度等级推荐
    // 考虑完成率、评分、热度等因素
  }
}
```

### 2. 产品分类筛选
```dart
class CheckinService {
  List<CheckinProduct> filterByCategory(List<CheckinProduct> products, String category) {
    return products.where((product) => product.category == category).toList();
  }
  
  List<CheckinProduct> filterByDifficulty(List<CheckinProduct> products, String difficulty) {
    return products.where((product) => product.difficulty == difficulty).toList();
  }
}
```

### 3. 产品搜索功能
```dart
class CheckinService {
  List<CheckinProduct> searchProducts(List<CheckinProduct> products, String query) {
    // 支持按名称、描述、标签搜索
    // 支持模糊匹配
  }
}
```

## 📝 改造优先级

### 第一阶段：Checkin页面（高优先级）
1. ✅ 基础数据从 API 获取（`id`, `name`, `description`, `videoUrl`）
2. ✅ 实现 MVVM 架构
3. ✅ 添加错误处理
4. ✅ 添加加载状态
5. ✅ 视频加载失败回退机制
6. ❌ 产品状态管理（已移除，简化设计）

### 第二阶段：Training List页面（中优先级）
1. 🔄 详细数据获取（`GET /training/products/{productId}`）
2. 🔄 图标URL支持（替代随机图标）
3. 🔄 缓存机制
4. 🔄 离线支持

### 第三阶段：功能增强（低优先级）
1. 🎨 分类筛选功能
2. 🎨 搜索功能
3. 🎨 推荐算法
4. 🎨 动画效果优化
5. 🎨 性能优化

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

## 🎯 设计理念

### 当前策略
- **简化优先**: 卡片信息精简，突出核心功能
- **快速操作**: 一键进入训练，减少用户思考时间
- **视觉吸引**: 视频背景和随机图标增强用户体验
- **稳定可靠**: 完善的错误处理和回退机制
- **分步加载**: 按需获取数据，优化性能

### 技术特点
- **随机图标**: 无需API获取，减少网络请求
- **智能视频**: 网络优先，本地回退，确保视频播放
- **固定路由**: 简化逻辑，统一跳转目标
- **响应式设计**: 适配不同屏幕尺寸
- **分阶段API**: 简化版 + 详细版，按需加载

### 数据流设计
```
Checkin页面 → 简化数据 → 用户点击 → Training List页面 → 详细数据
     ↓              ↓              ↓              ↓              ↓
  快速加载      基础信息      传递ID      按需获取      完整展示
```

---

**总结**: 通过 MVVM 架构改造，Checkin 页面将保持简洁高效的设计理念，同时具备更好的可维护性、可测试性和可扩展性。当前专注于核心功能，未来可根据需求逐步扩展。
