# TrainingRulePage MVVM 改造规划

## 1. 页面概述

`TrainingRulePage` 是训练规则页面，显示特定训练项目的规则、投影教程和开始训练功能。

## 2. 当前数据结构分析

### 2.1 伪数据定义

```dart
// 训练规则数据
final List<Map<String, dynamic>> fakeTrainingRules = [
  {
    "title": "Device Setup",
    "description": "Switch to P10 mode and P9 speed for optimal training experience",
  },
  // ...
];

// 视频教程信息
final Map<String, dynamic> fakeVideoInfo = {
  "videoUrl": "https://github.com/WiiMadHIIT/hiit-cdn/tree/main/video/video1.mp4",
  "title": "Watch Video Tutorial",
};

// 教程步骤数据
final List<Map<String, dynamic>> fakeTutorialSteps = [
  {
    "number": 1,
    "title": "Find a Flat Surface",
    "description": "Choose a wall or flat surface that is at least 2 meters wide and 1.5 meters tall.",
  },
  // ...
];
```

### 2.2 页面接收参数

```dart
class TrainingRulePage extends StatefulWidget {
  final String? trainingId; // 从路由传递的训练ID
}
```

## 3. 需要从后端API获取的参数

### 3.1 页面标题和描述
- **页面标题**: 当前硬编码为 "Training Rules" - **固定值，无需从API获取**
- **页面副标题**: 当前硬编码为 "Get ready for your workout" - **固定值，无需从API获取**

### 3.2 训练规则数据
- **规则列表**: 当前使用 `fakeTrainingRules` 硬编码数据
- **规则标题**: 每个规则的标题
- **规则描述**: 每个规则的详细描述

### 3.3 投影教程数据
- **教程视频信息**: 当前使用 `fakeVideoInfo` 硬编码数据
  - `videoUrl`: 教程视频链接
  - `title`: 教程标题
- **教程步骤**: 当前使用 `fakeTutorialSteps` 硬编码数据
  - `number`: 步骤编号
  - `title`: 步骤标题
  - `description`: 步骤描述

### 3.4 训练基本信息
- **训练名称**: 基于 `trainingId` 获取的训练名称 - **页面中未使用，可移除**
- **训练类型**: 训练的分类信息 - **页面中未使用，可移除**
- **训练难度**: 训练的难度级别 - **页面中未使用，可移除**

### 3.5 训练跳转配置
- **跳转类型**: 根据训练类型决定跳转到哪个页面
  - `/checkin_countdown`: 倒计时页面（当前硬编码）
  - `/checkin_training_voice`: 语音训练页面
  - `/checkin_training`: 普通训练页面
- **跳转逻辑**: 需要基于 `trainingId` 或训练类型动态决定跳转目标

## 4. 建议的API接口设计

### 4.1 主要API接口

```
GET /api/checkin/rules/{trainingId}?productId={productId}
```

### 4.1.1 跳转逻辑说明

当前 `_startTraining()` 方法硬编码跳转到 `/checkin_countdown`，需要改为根据 `trainingConfig.nextPageRoute` 动态跳转。同时，跳转时需要传递 `trainingId` 和 `productId` 两个参数：

| 跳转目标 | 说明 |
|----------|------|
| `/checkin_countdown` | 倒计时页面 - 需要准备时间的训练 |
| `/checkin_training_voice` | 语音训练页面 - 需要语音指导的训练 |
| `/checkin_training` | 普通训练页面 - 直接开始训练 |

### 4.2 API响应数据结构

```json
{
  "code": "200",
  "message": "Success",
  "data": {
    "trainingId": "training_001",
    "productId": "hiit_pro_001",
    "trainingRules": [
      {
        "id": "rule_001",
        "title": "Device Setup",
        "description": "Switch to P10 mode and P9 speed for optimal training experience",
        "order": 1
      },
      {
        "id": "rule_002", 
        "title": "System Calibration",
        "description": "Wait 3 seconds after adjustment for system to respond",
        "order": 2
      },
      {
        "id": "rule_003",
        "title": "Ready Check", 
        "description": "Ensure you are in a safe environment with proper space",
        "order": 3
      }
    ],
    "projectionTutorial": {
      "videoInfo": {
        "videoUrl": "https://github.com/WiiMadHIIT/hiit-cdn/tree/main/video/video1.mp4",
        "title": "Watch Video Tutorial"
      },
      "tutorialSteps": [
        {
          "number": 1,
          "title": "Find a Flat Surface",
          "description": "Choose a wall or flat surface that is at least 2 meters wide and 1.5 meters tall."
        },
        {
          "number": 2,
          "title": "Position Your Device", 
          "description": "Place your device on a stable surface, approximately 1-2 meters from the projection surface."
        },
        {
          "number": 3,
          "title": "Enable Projection",
          "description": "Tap the projection button in the training interface to start casting."
        },
        {
          "number": 4,
          "title": "Adjust Position",
          "description": "Use the on-screen controls to adjust the projection size and position."
        },
        {
          "number": 5,
          "title": "Start Training",
          "description": "Once the projection is properly set up, you can begin your training session."
        }
      ]
    },
    "trainingConfig": {
      "nextPageRoute": "/checkin_countdown"
    }
  }
}
```

### 4.3 API参数说明

#### 4.3.1 路径参数
- **trainingId** (必需): 训练ID，用于标识具体的训练项目

#### 4.3.2 查询参数
- **productId** (必需): 产品ID，用于标识产品类型，影响训练规则和配置的生成

## 5. MVVM架构设计

### 5.1 数据层 (/data)

#### 5.1.1 API模型
- `training_rule_api_model.dart`: 定义API响应数据结构
- `training_api.dart`: API客户端，调用后端接口

#### 5.1.2 Repository
- `training_rule_repository.dart`: 数据仓库，处理数据获取和转换

### 5.2 领域层 (/domain)

#### 5.2.1 实体
- `training_rule.dart`: 训练规则实体
- `projection_tutorial.dart`: 投影教程实体
- `training_config.dart`: 训练配置实体（包含跳转逻辑）

#### 5.2.2 服务
- `training_rule_service.dart`: 训练规则业务逻辑

#### 5.2.3 用例
- `get_training_rule_usecase.dart`: 获取训练规则用例

### 5.3 表现层 (/presentation)

#### 5.3.1 ViewModel
- `training_rule_viewmodel.dart`: 管理页面状态和业务逻辑

#### 5.3.2 页面改造
- 将 `TrainingRulePage` 改造为使用MVVM架构
- 使用 `Provider` 进行状态管理

## 6. 改造优先级

### 6.1 高优先级
1. ✅ 创建数据层 (API, Models, Repository)
2. ✅ 创建领域层 (Entities, Services, UseCases)  
3. ✅ 创建ViewModel
4. ✅ 改造页面使用MVVM架构

### 6.2 中优先级
5. 🔄 实现后端API接口
6. 🔄 添加错误处理和加载状态
7. 🔄 优化UI交互体验

### 6.3 低优先级
8. ⏳ 添加缓存机制
9. ⏳ 实现离线模式
10. ⏳ 添加国际化支持

## 7. 技术要点

### 7.1 图标和颜色处理
- 保持现有的随机图标和颜色生成逻辑
- 图标和颜色在客户端动态生成，不依赖后端

### 7.2 视频处理
- 支持网络视频URL
- 添加视频加载失败的回退机制

### 7.3 路由参数
- 继续使用 `trainingId` 作为路由参数
- 确保与现有路由系统兼容

### 7.4 固定UI元素
- 页面标题 "Training Rules" 和副标题 "Get ready for your workout" 保持固定
- 这些元素在UI中硬编码，无需从API获取

### 7.6 参数传递机制
- **trainingId**: 从路由参数获取，用于标识具体训练项目
- **productId**: 从路由参数获取，用于标识产品类型
- 两个参数都需要在页面跳转时传递给后续的训练页面
- API调用时使用 `trainingId` 作为路径参数，`productId` 作为查询参数

### 7.5 跳转逻辑处理
- 根据 `trainingConfig.nextPageRoute` 动态决定跳转目标
- 支持三种跳转类型：
  - `/checkin_countdown`: 倒计时页面
  - `/checkin_training_voice`: 语音训练页面
  - `/checkin_training`: 普通训练页面
- 跳转逻辑在 `_startTraining()` 方法中实现
- 如果 `nextPageRoute` 无效，默认跳转到 `/checkin_countdown`

## 8. 预期效果

### 8.1 功能改进
- 动态获取训练规则内容
- 支持不同训练项目的个性化规则
- 灵活的投影教程配置
- 保持UI一致性（固定标题和副标题）
- 智能跳转逻辑（根据训练类型选择合适的目标页面）
- 完整的参数传递机制（trainingId + productId）

### 8.2 架构优势
- 清晰的职责分离
- 易于测试和维护
- 支持数据缓存和离线模式
- 简化的API数据结构

### 8.3 用户体验
- 更快的页面加载速度
- 更好的错误处理
- 更丰富的训练规则内容
- 一致的页面布局和导航体验
