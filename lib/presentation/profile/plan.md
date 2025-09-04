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
  - `timestep` - 获得荣誉的时间戳（毫秒）

### 4. 挑战记录数据（必需）
- ✅ **`challengeRecords`** - 挑战记录列表，包含：
  - `id` - 记录唯一标识符
  - `challengeId` - 挑战ID，用于与激活关联数据对应
  - `index` - 排名
  - `name` - 挑战名称（当前硬编码为 'HIIT 7-Day Challenge', 'Yoga Masters Cup'）
  - `status` - 挑战状态（'ended'、'ongoing' 或 'ready'）
  - `timestep` - 时间戳（毫秒）
  - `rank` - 获得名次（'1st', '2nd', '3rd' 或 'N/A'）

### 5. 打卡记录数据（必需）
- ✅ **`checkinRecords`** - 打卡记录列表，包含：
  - `id` - 记录唯一标识符
  - `productId` - 产品ID，用于与激活关联数据对应
  - `index` - 序号
  - `name` - 训练名称（当前硬编码为 'HIIT Pro', 'Yoga Flex'）
  - `status` - 活动状态（'ended'、'ongoing' 或 'ready'）
  - `timestep` - 时间戳（毫秒）
  - `rank` - 排名（'1st', '2nd', '3rd' 或 'N/A'）

### 6. 激活关联数据（必需）
- ✅ **`activate`** - 挑战与产品的关联列表，包含：
  - `challengeId` - 挑战ID，与 `challengeRecords` 中的挑战对应
  - `challengeName` - 挑战名称，便于UI显示和用户识别
  - `productId` - 产品ID，与对应的产品服务关联
  - `productName` - 产品名称，便于UI显示和用户识别

### 7. 激活码提交API（新增）
- 🔄 **激活码提交接口** - 用于提交激活码进行验证
  - **接口地址**: `POST /api/profile/activate`
  - **请求参数**:
    ```json
    {
      "productId": "product_001",
      "activationCode": "ABC123DEF456"
    }
    ```
  - **响应格式**:
    ```json
    {
      "code": "A200",
      "message": "success",
      "data": {
        "submitted": true,
        "message": "Activation request submitted successfully"
      }
    }
    ```
  - **业务逻辑**: 
    - 提交后不等待返回状态，直接提示用户
    - 成功提交后显示"激活已申请，请耐心等待1-5天进行审核"
    - 失败后提示"提交失败，请重新提交"
    - 审核通过后，对应的挑战/打卡记录会出现在 `challengeRecords` 和 `checkinRecords` 中，状态为 `ready`

### 6. 建议新增的参数
- 🏆 **`achievements`** - 成就列表
- 📈 **`weeklyStats`** - 周统计数据
- 📈 **`monthlyStats`** - 月统计数据
- 🎯 **`goals`** - 目标设置
- 👥 **`friends`** - 好友列表
- 💎 **`points`** - 积分

## 📊 建议的 API 数据结构

### 获取用户资料接口（基础信息，不含列表）
**接口地址**: `GET /api/profile/list`

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
      "points": 2500
    },
    "stats": {
      "currentStreak": 36,
      "daysThisYear": 120
    },
    "honors": [
      {
        "id": "honor_001",
        "icon": "emoji_events",
        "label": "Overall Champion",
        "description": "HIIT Winner 2023",
        "timestep": 1703980800000  // 2023-12-31 获得时间
      },
      {
        "id": "honor_002",
        "icon": "star",
        "label": "Best Streak",
        "description": "60-Day Check-in Streak",
        "timestep": 1700006400000  // 2023-11-15 获得时间
      }
    ]
  }
}
```

### 激活码提交接口
**接口地址**: `POST /api/profile/activate`

**请求参数**:
```json
{
  "productId": "product_001",
  "activationCode": "ABC123DEF456"
}
```

**响应格式**:
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "submitted": true,
    "message": "Activation request submitted successfully"
  }
}
```

### 用户信息修改接口
**接口地址**: `PUT /api/profile/update`

**请求参数**:
```json
{
  "username": "New Username",  // 如果修改了用户名，传入新值；如果没修改，传入 null
  "email": "new.email@example.com"  // 如果修改了邮箱，传入新值；如果没修改，传入 null
}
```

**成功响应格式**:
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "updated": true,
    "message": "Profile updated successfully"
  }
}
```

```

**业务逻辑**:
- 只更新用户修改的字段，未修改的字段传入 `null`
- 后端验证修改后的字段格式和唯一性
- 成功更新后只返回成功状态，不返回用户信息
- 失败时返回具体的验证错误信息
- 前端根据成功状态决定是否更新本地数据

## 🏗️ MVVM 架构改造计划

### 1. 目录结构
```
lib/
  data/
    api/
      profile_api.dart              // API 请求
    models/
      profile_api_model.dart        // API 数据模型（包含激活相关字段）
    repository/
      profile_repository.dart       // 数据仓库
  domain/
    entities/
      profile.dart                  // 业务实体
    services/
      profile_service.dart         // 业务服务
    usecases/
      get_profile_usecase.dart     // 获取用户资料
      submit_activation_usecase.dart // 提交激活码
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
- **`activation_request.dart`**: 激活请求业务实体
- **`profile_service.dart****: 复杂业务逻辑（如统计计算、成就解锁、用户信息更新）
- **`get_profile_usecase.dart`**: 获取用户资料的业务流程
- **`submit_activation_usecase.dart`**: 提交激活码的业务流程
- **`update_profile_usecase.dart`**: 更新用户信息的业务流程

#### **Data 层**
- **`profile_api.dart`**: 网络请求封装（包含用户信息更新接口）
- **`profile_api_model.dart`**: API 响应数据结构（包含激活相关字段和用户信息更新响应）
- **`profile_repository.dart`**: 数据转换和缓存（包含用户信息更新方法）

#### **Presentation 层**
- **`profile_page.dart`**: 纯 UI 展示，通过 Provider 监听状态
- **`profile_viewmodel.dart`**: 状态管理，调用 UseCase（包含用户信息更新状态管理）
- **`user_profile_edit_sheet.dart`**: 用户信息编辑弹窗（已实现，需要集成更新逻辑）

### 3. 改造步骤

#### **第一步：创建 Domain 层**
1. 创建业务实体类
2. 创建 `profile_service.dart` 业务服务
3. 创建 UseCase 类（get_profile_usecase.dart、submit_activation_usecase.dart 和 update_profile_usecase.dart）

#### **第二步：创建 Data 层**
1. 创建 `profile_api_model.dart` API 模型（包含激活相关字段和用户信息更新响应）
2. 创建 `profile_api.dart` API 请求（包含用户信息更新接口）
3. 创建 `profile_repository.dart` 数据仓库（包含用户信息更新方法）

#### **第三步：创建 Presentation 层**
1. 创建 `profile_viewmodel.dart` 状态管理（包含用户信息更新状态）
2. 重构 `profile_page.dart` 为纯 UI 组件
3. 集成激活码提交功能
4. 集成用户信息更新功能（连接 `user_profile_edit_sheet.dart`）

#### **第四步：集成测试**
1. 测试数据流
2. 测试错误处理
3. 测试状态管理
4. 测试激活码提交流程
5. 测试用户信息更新流程

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
8. 🎁 激活关联展示（挑战与产品关联，便于用户了解可获得的奖励）

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

### 4. 激活关联管理
```dart
class ProfileService {
  List<Activate> getAvailableActivations(List<ChallengeRecord> challenges) {
    // 获取可激活的挑战与产品关联
  }
  
  bool canActivateChallenge(String challengeId, UserStats stats) {
    // 检查用户是否有资格激活特定挑战
  }
}
```

### 5. 激活码提交管理（复用 profile 结构）
```dart
class ProfileService {
  Future<bool> submitActivationCode(String productId, String activationCode) async {
    // 提交激活码进行验证
    // 返回提交是否成功
  }
  
  void handleActivationSuccess() {
    // 处理激活成功后的业务逻辑
    // 显示审核等待提示
  }
  
  void handleActivationFailure() {
    // 处理激活失败后的业务逻辑
    // 提示用户重新提交
  }
}
```

### 6. 用户信息更新管理
```dart
class ProfileService {
  Future<bool> updateUserProfile({
    String? username,
    String? email,
  }) async {
    // 只更新用户修改的字段，未修改的传入 null
    // 调用 PUT /api/profile/update 接口
    // 返回更新是否成功
  }
  
  void handleProfileUpdateSuccess() {
    // 处理用户信息更新成功后的业务逻辑
    // 根据用户修改的字段更新本地用户信息
    // 显示成功提示
    // 关闭编辑弹窗
  }
  
  void handleProfileUpdateFailure(Map<String, String> errors) {
    // 处理用户信息更新失败后的业务逻辑
    // 显示具体的验证错误信息
    // 保持弹窗打开，允许用户重新输入
  }
  
  bool validateProfileChanges({
    String? username,
    String? email,
  }) {
    // 验证用户输入的信息
    // 返回验证是否通过
  }
  
  void updateLocalProfile({
    String? username,
    String? email,
  }) {
    // 根据API返回的成功状态，更新本地用户信息
    // 只更新用户实际修改的字段
    // 保持其他字段不变
  }
}
```

## 📝 改造优先级

### 高优先级（立即改造）
1. ✅ 基础用户信息从 API 获取
2. ✅ 统计数据从 API 获取
3. ✅ 实现 MVVM 架构
4. ✅ 添加错误处理
5. 🔄 激活码提交功能
6. 🔄 用户信息更新功能

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

## 🔄 数据结构一致性说明

### 挑战记录、打卡记录与荣誉墙统一结构
为了保持代码的一致性和可维护性，挑战记录、打卡记录和荣誉墙现在使用完全相同的字段结构：

```dart
// 通用记录结构
{
  "id": "unique_id",
  "index": 1,                    // 荣誉墙可选
  "name": "活动名称",             // 荣誉墙为荣誉标题
  "status": "ended" | "ongoing", // 统一状态字段（荣誉墙为获得状态）
  "timestep": 1709344800000,     // 统一时间戳字段
  "rank": "1st" | "2nd" | "3rd" | "N/A"  // 统一排名字段（荣誉墙为荣誉等级）
}

// 挑战记录结构（包含challengeId）
{
  "id": "unique_id",
  "challengeId": "challenge_xxx", // 挑战ID，用于与激活关联数据对应
  "index": 1,
  "name": "挑战名称",
  "status": "ended" | "ongoing" | "ready",
  "timestep": 1709344800000,
  "rank": "1st" | "2nd" | "3rd" | "N/A"
}

// 打卡记录结构（包含productId）
{
  "id": "unique_id",
  "productId": "product_xxx",     // 产品ID，用于与激活关联数据对应
  "index": 1,
  "name": "训练名称",
  "status": "ended" | "ongoing" | "ready",
  "timestep": 1709344800000,
  "rank": "1st" | "2nd" | "3rd" | "N/A"
}

// 激活关联结构（复用 profile 通用结构）
{
  "challengeId": "challenge_001",     // 挑战ID
  "challengeName": "HIIT 7-Day Challenge",  // 挑战名称
  "productId": "product_001",         // 对应的产品ID
  "productName": "HIIT Pro Training Kit"    // 产品名称
}
```

### 激活码相关数据结构简化
为了简化设计，激活码相关的数据结构采用以下策略：

1. **`activation_request.dart`**: 只在 entities 层添加，用于激活码提交的业务逻辑
2. **API 模型**: 激活相关字段直接集成到 `profile_api_model.dart` 中，复用现有的 profile 结构
3. **Repository**: 激活相关方法直接添加到 `profile_repository.dart` 中
4. **Service**: 激活相关业务逻辑直接添加到 `profile_service.dart` 中

这样可以减少不必要的文件创建，保持代码结构简洁，同时复用现有的 profile 相关基础设施。

### 状态字段说明
- **`status`**: 
  - `'ended'` - 活动已结束，显示排名和完成时间
  - `'ongoing'` - 活动进行中，显示倒计时和参与状态
  - `'ready'` - 活动准备就绪，用户有资格参与，显示准备状态和开始提示

### 时间字段说明
- **`timestep`**: 毫秒级时间戳（统一时间字段）
  - 格式：`DateTime.now().add/subtract().millisecondsSinceEpoch`
  - 对于已结束活动：表示活动结束时间（过去时间）
  - 对于进行中活动：表示活动截止时间（未来时间）
  - 对于荣誉墙：表示获得荣誉的时间（过去时间）
  - 替代了原来的 `participatedAt`、`lastCheckinAt` 和 `earnedAt` 字段
  - 示例：
    - 已结束活动：`1709344800000` (2小时前)
    - 进行中活动：`1709352000000` (2小时后)
    - 荣誉获得：`1703980800000` (2023-12-31)

### 排名字段说明
- **`rank`**: 
  - `'1st'`, `'2nd'`, `'3rd'` - 前三名
  - `'N/A'` - 未获得排名（通常用于进行中的活动）

## 🔄 激活码提交流程说明

### 用户操作流程
1. **输入激活码**: 用户在 `ActivateProductSheet` 中输入激活码
2. **提交验证**: 点击 "Activate" 按钮，调用 `POST /api/profile/activate` 接口
3. **参数传递**: 同时传递 `productId` 和 `activationCode`
4. **异步处理**: 不等待API返回状态，直接进行下一步处理

### 数据结构复用说明
- **激活请求**: 使用 `entities/activation_request.dart` 中的 `ActivationRequest` 实体
- **激活响应**: 直接集成到 `profile_api_model.dart` 中，复用现有的响应结构
- **激活逻辑**: 在 `profile_service.dart` 中添加激活相关方法，复用现有的业务逻辑框架

### 成功提交流程
1. **显示成功提示**: "激活已申请，请耐心等待1-5天进行审核"
2. **关闭弹窗**: 自动关闭激活弹窗
3. **等待审核**: 用户需要等待后台审核
4. **审核通过**: 审核通过后，对应的挑战/打卡记录会出现在列表中，状态为 `ready`

### 失败提交流程
1. **显示失败提示**: "提交失败，请重新提交"
2. **保持弹窗**: 弹窗保持打开状态
3. **清空输入**: 清空激活码输入框
4. **允许重试**: 用户可以重新输入激活码进行提交

### 状态变化说明
- **提交前**: 用户看到可激活的产品列表
- **提交中**: 显示加载状态，防止重复提交
- **提交成功**: 显示审核等待提示
- **审核通过**: 在 `challengeRecords` 和 `checkinRecords` 中出现 `ready` 状态的项目
- **审核失败**: 用户需要重新提交激活码

## 🔄 用户信息更新流程说明

### 用户操作流程
1. **打开编辑弹窗**: 用户点击编辑按钮，打开 `UserProfileEditSheet`
2. **修改信息**: 用户修改用户名或邮箱（或两者都修改）
3. **提交更新**: 点击 "Save Changes" 按钮，调用 `PUT /api/profile/update` 接口
4. **参数传递**: 只传递修改的字段，未修改的字段传入 `null`
5. **异步处理**: 等待API返回结果，根据结果决定下一步操作

### 数据结构复用说明
- **更新请求**: 使用现有的 profile 相关结构，只传递修改的字段
- **更新响应**: 简化的响应格式，只返回成功状态
- **更新逻辑**: 在 `profile_service.dart` 中添加更新相关方法，复用现有的业务逻辑框架

### 成功更新流程
1. **显示成功提示**: "Profile updated successfully"
2. **更新本地数据**: 根据用户修改的字段更新本地用户信息
3. **关闭弹窗**: 自动关闭编辑弹窗
4. **刷新UI**: 页面显示更新后的用户信息

### 失败更新流程
1. **显示失败提示**: 显示具体的验证错误信息
2. **保持弹窗**: 弹窗保持打开状态
3. **显示错误**: 在对应输入框下方显示错误信息
4. **允许重试**: 用户可以重新输入信息进行提交

### 状态变化说明
- **更新前**: 用户看到当前用户信息，可以修改
- **更新中**: 显示加载状态，防止重复提交
- **更新成功**: 显示成功提示，关闭弹窗，更新本地数据
- **更新失败**: 显示错误信息，保持弹窗打开，允许重试

---

**总结**: 通过 MVVM 架构改造，Profile 页面将具备更好的可维护性、可测试性和可扩展性，同时提供更丰富的用户统计和成就系统功能。统一的数据结构确保了挑战记录和打卡记录在 UI 展示和业务逻辑上的一致性。新增的激活码提交功能完善了用户激活产品的完整流程，提供了清晰的用户反馈和状态管理。用户信息更新功能允许用户实时修改个人资料，支持部分字段更新，提供友好的验证反馈和错误处理。

**架构简化优势**: 
- 只在 entities 层添加 `activation_request.dart`，减少文件创建
- 激活相关字段直接集成到现有的 profile 结构中，复用通用基础设施
- 用户信息更新功能复用现有的 profile 相关基础设施，无需创建额外的文件
- 保持代码结构简洁，便于维护和扩展
- 符合 DRY（Don't Repeat Yourself）原则，避免重复代码

### 获取激活关联分页接口（独立）

为便于前端单独获取 Profile 中的 "activate" 列表，提供独立分页接口，数据结构参考 `ActivateGeneralPageDto`（不包含 `equipmentIds` 字段）。

- 接口地址: `GET /api/profile/activate/list`
- 请求参数:
  - `page` 整数，页码（从1开始，默认1）
  - `size` 整数，每页大小（默认10）

- 成功响应示例:
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "activate": [
      {
        "challengeId": "20000000",
        "challengeName": "Christmas Boxing Challenge",
        "productId": "1000000000",
        "productName": "WiiMad Music Boxing Machine Beat X"
      },
      {
        "challengeId": "20000001",
        "challengeName": "Holiday Pilates Flow Challenge",
        "productId": "1000000001",
        "productName": "Plymax Pilates Reformer Flow X"
      }
    ],
    "total": 2,
    "currentPage": 1,
    "pageSize": 10
  }
}
```

- 数据结构说明:
  - `activate` 列表项（ActivateGeneralDto）
    - `challengeId`: 挑战ID
    - `challengeName`: 挑战名称
    - `productId`: 关联产品ID（equipmentId）
    - `productName`: 关联产品名称
  - `total`: 总记录数
  - `currentPage`: 当前页
  - `pageSize`: 每页大小

- 备注:
  - 该接口仅返回分页所需信息，不包含 `equipmentIds` 聚合字段；若需要批量设备详情，可调用设备服务的批量查询接口（如 `/equipment/map-by-ids`）。

### 获取打卡记录分页接口（独立）

为便于前端单独获取 Profile 中的 "checkinRecords" 列表，提供独立分页接口，数据结构与 Profile 主接口解耦（仅分页所需字段）。

- 接口地址: `GET /api/profile/checkin/list`
- 请求参数:
  - `page` 整数，页码（从1开始，默认1）
  - `size` 整数，每页大小（默认10）

- 成功响应示例:
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "checkinRecords": [
      {
        "id": "checkin_001",
        "productId": "1000000000",
        "index": 1,
        "name": "HIIT Pro",
        "status": "ended",
        "timestep": 1709344800000,
        "rank": "2nd"
      },
      {
        "id": "checkin_002",
        "productId": "1000000001",
        "index": 2,
        "name": "Yoga Flex",
        "status": "ongoing",
        "timestep": 1709352000000,
        "rank": "N/A"
      }
    ],
    "total": 2,
    "currentPage": 1,
    "pageSize": 10
  }
}
```

- 数据结构说明:
  - `checkinRecords` 列表项（与 `GET /api/profile/list` 的 `checkinRecords` 相同）
    - `id`: 记录唯一标识符
    - `productId`: 关联产品ID
    - `index`: 序号
    - `name`: 训练/打卡名称
    - `status`: `ended` | `ongoing` | `ready`
    - `timestep`: 毫秒级时间戳
    - `rank`: `1st` | `2nd` | `3rd` | `N/A`
  - `total`: 总记录数
  - `currentPage`: 当前页
  - `pageSize`: 每页大小

- 备注:
  - 该接口仅返回分页所需的打卡记录列表与分页元数据；
  - 如需批量补充产品详情（如缩略图、描述），建议调用设备服务的批量查询接口进行聚合。

### 获取挑战记录分页接口（独立）

为便于前端单独获取 Profile 中的 "challengeRecords" 列表，提供独立分页接口，数据结构与 Profile 主接口解耦（仅分页所需字段）。

- 接口地址: `GET /api/profile/challenge/list`
- 请求参数:
  - `page` 整数，页码（从1开始，默认1）
  - `size` 整数，每页大小（默认10）

- 成功响应示例:
```json
{
  "code": "A200",
  "message": "success",
  "data": {
    "challengeRecords": [
      {
        "id": "challenge_001",
        "challengeId": "20000000",
        "index": 1,
        "name": "Christmas Boxing Challenge",
        "status": "ended",
        "timestep": 1709251200000,
        "rank": "2nd"
      },
      {
        "id": "challenge_002",
        "challengeId": "20000001",
        "index": 2,
        "name": "Holiday Pilates Flow Challenge",
        "status": "ready",
        "timestep": 1709431200000,
        "rank": "N/A"
      }
    ],
    "total": 2,
    "currentPage": 1,
    "pageSize": 10
  }
}
```

- 数据结构说明:
  - `challengeRecords` 列表项（与 `GET /api/profile/list` 的 `challengeRecords` 相同）
    - `id`: 记录唯一标识符
    - `challengeId`: 挑战ID（与激活/赛事等关联）
    - `index`: 序号
    - `name`: 挑战名称
    - `status`: `ended` | `ongoing` | `ready`
    - `timestep`: 毫秒级时间戳
    - `rank`: `1st` | `2nd` | `3rd` | `N/A`
  - `total`: 总记录数
  - `currentPage`: 当前页
  - `pageSize`: 每页大小

- 备注:
  - 该接口仅返回分页所需的挑战记录列表与分页元数据；
  - 如需补充挑战详情（更丰富文案、图标等），建议调用挑战服务或配置服务的相应查询接口。