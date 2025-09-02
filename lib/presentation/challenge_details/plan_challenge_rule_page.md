# Challenge Rule Page 改造规划

## 一、改造目标

将现有的 `challenge_rule_page.dart` 从使用硬编码伪数据改造为完整的 API 驱动架构，参考 `training_rule_page.dart` 的分层架构模式。

## 二、API 接口设计

### 请求接口
```
GET /api/challenge/rules/{challengeId}
```

### 请求参数
- `challengeId`: 挑战ID（路径参数）

### 响应数据结构
```json
{
    "code": "A200",
    "message": "success",
    "data": {
        "challengeId": "challenge_001",
        "totalRounds": 3,
        "roundDuration": 80,
        "challengeRules": [
            {
                "id": "rule_001",
                "title": "Device Setup",
                "description": "Switch to P10 mode and P9 speed for optimal challenge experience",
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
                "videoUrl": "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video1.mp4",
                "title": "Challenge Tutorial"
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
                    "description": "Tap the projection button in the challenge interface to start casting."
                }
            ]
        },
        "challengeConfig": {
            "nextPageRoute": "/challenge_game",
            "isActivated": true,
            "isQualified": true,
            "allowedTimes"：5
        }
    },
    "traceId": null,
    "timestamp": 1755094300296,
    "success": true
}
```

## 三、分层架构设计

### 1. 数据层（Data Layer）
- **challenge_rule_api.dart**: API 接口封装
- **challenge_rule_api_model.dart**: API 数据模型
- **challenge_rule_repository.dart**: 数据仓库

### 2. 领域层（Domain Layer）
- **challenge_rule.dart**: 挑战规则实体
- **challenge_config.dart**: 挑战配置实体
- **challenge_rule_service.dart**: 挑战规则服务
- **get_challenge_rule_usecase.dart**: 获取挑战规则用例

### 3. 表现层（Presentation Layer）
- **challenge_rule_viewmodel.dart**: 挑战规则视图模型
- **challenge_rule_page.dart**: 挑战规则页面（改造现有页面）

## 四、核心实体设计

### ChallengeRule 实体
- `id`: 规则ID
- `title`: 规则标题
- `description`: 规则描述
- `order`: 排序顺序
- 业务方法：`isValid`, `displayTitle`, `displayDescription`

### ChallengeConfig 实体
- `nextPageRoute`: 下一个页面路由
- `isActivated`: 是否已激活
- `isQualified`: 是否已获得资格
- 业务方法：`isValid`, `canStartChallenge`

## 五、业务逻辑设计

### 挑战规则验证
- 验证挑战规则数据的完整性
- 检查挑战是否已激活
- 验证用户是否已获得挑战资格

### 状态管理
- 加载状态（loading）
- 错误状态（error）
- 成功状态（success）
- 资格状态（isQualified）
- 激活状态（isActivated）

### 路由控制
- 根据 `isActivated` 和 `isQualified` 控制开始挑战按钮状态
- 动态跳转到相应的挑战页面

## 六、UI 交互设计

### 状态显示
- 未激活状态：显示激活提示，禁用开始按钮
- 未获得资格：显示资格获取提示，禁用开始按钮
- 已激活且已获得资格：正常显示，启用开始按钮

### 错误处理
- 网络请求失败：显示重试按钮
- 数据加载失败：显示错误信息和重试选项
- 资格验证失败：显示资格获取指导

### 响应式设计
- 保持现有的响应式布局
- 支持不同屏幕尺寸的适配

## 七、改造步骤

### 第一阶段：创建数据层
1. 创建 API 模型类
2. 实现 API 接口
3. 创建数据仓库

### 第二阶段：创建领域层
1. 创建领域实体
2. 实现领域服务
3. 创建用例类

### 第三阶段：创建表现层
1. 实现 ViewModel
2. 改造现有页面
3. 集成状态管理

### 第四阶段：测试和优化
1. 单元测试
2. 集成测试
3. UI 测试
4. 性能优化

## 八、关键差异点

### 与 TrainingRule 的区别
1. **请求参数**: 只有 `challengeId`，没有 `trainingId` 和 `productId`
2. **返回数据**: 包含 `challengeInfo` 而不是 `trainingId` 和 `productId`
3. **配置字段**: 包含 `isActivated` 和 `isQualified` 状态字段
4. **业务逻辑**: 需要验证挑战激活状态和用户资格

### 特殊处理
1. **资格验证**: 根据 `isQualified` 控制用户是否可以开始挑战
2. **激活状态**: 根据 `isActivated` 控制挑战是否可用
3. **错误处理**: 针对不同的资格和激活状态提供相应的用户指导

## 九、预期效果

改造完成后，`challenge_rule_page.dart` 将具备：
1. 完整的 API 数据驱动
2. 清晰的分层架构
3. 完善的错误处理
4. 灵活的状态管理
5. 良好的用户体验
6. 易于维护和扩展的代码结构
