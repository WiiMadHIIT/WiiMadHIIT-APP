# TrainingListPage 通用模板使用说明

## 概述

`TrainingListPage` 现在是一个完全可配置的通用模板，支持从JSON配置文件或字符串动态加载数据，方便后续从后端API导入数据。

## 功能特性

- ✅ **动态配置**：支持JSON配置文件或字符串
- ✅ **视频播放**：支持自定义视频路径
- ✅ **文本配置**：所有文本内容都可配置
- ✅ **挑战列表**：动态加载挑战数据
- ✅ **错误处理**：配置加载失败时使用默认配置
- ✅ **加载状态**：显示加载指示器

## 使用方法

### 1. 使用默认配置

```dart
// 使用默认配置
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => TrainingListPage()),
);
```

### 2. 根据产品ID加载配置

```dart
// 根据产品ID加载对应配置
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TrainingListPage(productId: 'hiit_pro'),
  ),
);
```

### 3. 从JSON字符串加载

```dart
// 从JSON字符串加载配置
String jsonConfig = '''
{
  "videoPath": "assets/video/custom_video.mp4",
  "videoTitle": "Custom Video Title",
  "pageTitle": "Custom Page Title",
  "challenges": [...]
}
''';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TrainingListPage(configJson: jsonConfig),
  ),
);
```

### 4. 从配置文件加载

```dart
// 从assets配置文件加载
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TrainingListPage(
      configAssetPath: 'assets/configs/training_config.json',
    ),
  ),
);
```

### 5. 从后端API加载

```dart
// 从后端API获取配置
Future<void> loadFromAPI() async {
  final response = await http.get(Uri.parse('your-api-endpoint'));
  final jsonConfig = response.body;
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TrainingListPage(configJson: jsonConfig),
    ),
  );
}
```

### 6. 从后端API根据产品ID加载

```dart
// 从后端API根据产品ID获取配置
Future<void> loadFromAPIByProductId(String productId) async {
  final response = await http.get(
    Uri.parse('your-api-endpoint/training-config/$productId'),
  );
  final jsonConfig = response.body;
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TrainingListPage(configJson: jsonConfig),
    ),
  );
}
```

## JSON配置格式

### 完整配置示例

```json
{
  "videoPath": "assets/video/video1.mp4",
  "fallbackImagePath": "assets/images/beatx_bg.jpg",
  "pageTitle": "Beat X Challenges",
  "pageSubtitle": "Choose your rhythm and intensity",
  "challenges": [
    {
      "name": "Beginner Rhythm",
      "mode": "Classic",
      "speed": "60 BPM",
      "duration": "5 min",
      "difficulty": "Easy",
      "description": "Perfect for beginners to learn basic rhythm"
    }
  ]
}
```

### 配置字段说明

| 字段 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `videoPath` | String | 否 | `assets/video/video1.mp4` | 视频文件路径（支持本地路径或远程URL） |
| `fallbackImagePath` | String | 否 | `assets/images/beatx_bg.jpg` | 视频加载失败时的背景图片（支持本地路径或远程URL） |
| `pageTitle` | String | 否 | `Training Challenges` | 页面主标题 |
| `pageSubtitle` | String | 否 | `Choose your intensity` | 页面副标题 |
| `challenges` | Array | 否 | `[]` | 挑战列表 |

### 挑战对象格式

```json
{
  "name": "挑战名称",
  "mode": "模式",
  "speed": "速度",
  "duration": "时长",
  "difficulty": "难度",
  "description": "描述"
}
```

## 难度颜色映射

系统会根据难度自动分配颜色：

- **Easy** → 🟢 绿色
- **Medium** → 🟠 橙色  
- **Hard** → 🔴 红色
- **Expert** → 🟣 紫色
- **其他** → ⚫ 灰色

## 产品ID支持

当前支持的产品ID（模拟数据）：

| 产品ID | 产品名称 | 描述 |
|--------|----------|------|
| `hiit_pro` | HIIT Pro | 高强度间歇训练 |
| `yoga_flex` | Yoga Flex | 瑜伽灵活性训练 |
| `strength_training` | Strength Training | 力量训练 |
| `cardio_blast` | Cardio Blast | 有氧训练 |

### 扩展产品ID

在 `_getConfigByProductId()` 方法中添加新的产品配置：

```dart
case 'new_product_id':
  return TrainingPageConfig(
    videoPath: 'assets/video/new_video.mp4',
    videoTitle: 'New Product Title',
    // ... 其他配置
  );
```

## 错误处理

- 如果JSON解析失败，会使用默认配置
- 如果配置文件不存在，会使用默认配置
- 如果字段缺失，会使用默认值
- 如果产品ID不存在，会使用默认配置

## 扩展建议

### 1. 添加更多配置选项

```json
{
  "theme": {
    "primaryColor": "#FF0000",
    "backgroundColor": "#F8F9FA"
  },
  "animation": {
    "enableAnimations": true,
    "animationDuration": 300
  }
}
```

### 2. 支持多语言

```json
{
  "locale": "zh_CN",
  "translations": {
    "zh_CN": {
      "pageTitle": "训练挑战",
      "pageSubtitle": "选择你的强度"
    },
    "en_US": {
      "pageTitle": "Training Challenges",
      "pageSubtitle": "Choose your intensity"
    }
  }
}
```

### 3. 支持动态路由

```json
{
  "challenges": [
    {
      "name": "Beginner Rhythm",
      "route": "/challenge/beginner",
      "params": {
        "id": "beginner_001",
        "type": "rhythm"
      }
    }
  ]
}
```

## 界面说明

### 视频区域
- **标题**：固定为 "Must-see before workout"
- **目的**：统一用户体验，强调观看视频的重要性

### 页面标题区域
- **主标题**：可配置的页面标题（如 "HIIT Pro Challenges"）
- **副标题**：可配置的页面描述（如 "Push your limits with intense workouts"）

## 资源管理

### 本地资源
- 需要在 `pubspec.yaml` 中声明
- 使用 `assets/video/` 和 `assets/images/` 路径
- 打包到应用中，离线可用

### 远程资源（CDN）
- **不需要**在 `pubspec.yaml` 中声明
- 使用 `https://` 或 `http://` 开头的URL
- 需要网络连接，但可以动态更新

### 混合使用示例
```json
{
  "videoPath": "https://cdn.example.com/videos/training.mp4",  // 远程视频
  "fallbackImagePath": "assets/images/local_bg.jpg",           // 本地图片
  "pageTitle": "Custom Training",
  "pageSubtitle": "Choose your intensity",
  "challenges": [...]
}
```

## 文件结构

```
lib/presentation/checkin_start_training/
├── training_list_page.dart                    # 主模板文件
├── README.md                                  # 使用说明
└── assets/configs/
    ├── training_config_example.json           # 本地资源示例
    └── training_config_remote_example.json    # 远程资源示例
```

## 注意事项

1. 确保视频文件路径正确且文件存在
2. 图片文件路径需要正确配置
3. JSON格式必须有效
4. 建议在生产环境中添加配置验证
5. 考虑添加配置缓存机制以提高性能 