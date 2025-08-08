# Checkin Training API 模块

训练相关的API接口、数据模型和仓库层实现。

## 📁 文件结构

```
lib/data/
├── api/checkin_training_api.dart              # API接口
├── models/checkin_training_api_model.dart     # API数据模型
└── repository/checkin_training_repository.dart # 仓库层

lib/domain/entities/
├── checkin_training/                          # 训练相关实体
│   ├── training_result.dart                   # 训练结果实体
│   ├── training_history_item.dart             # 训练历史实体
│   └── training_session_config.dart           # 训练配置实体
```

## 🚀 使用方法

### 初始化
```dart
final api = CheckinTrainingApi();
final repository = CheckinTrainingRepositoryImpl(api);
```

### 获取训练数据
```dart
final result = await repository.getTrainingDataAndVideoConfig(
  'training_001',
  productId: 'product_001',
);
```

### 提交训练结果
```dart
final trainingResult = TrainingResult.create(
  trainingId: 'training_001',
  totalRounds: 3,
  roundDuration: 60,
  maxCounts: 25,
);

final response = await repository.submitTrainingResult(trainingResult);
```

### 获取历史记录
```dart
final history = await repository.getTrainingHistory('training_001');
```

## 📊 API 接口

- `GET /api/training/data` - 获取训练数据和视频配置
- `POST /api/training/submit` - 提交训练结果

## 🧪 测试

```dart
CheckinTrainingApiTest.runAllTests();
``` 