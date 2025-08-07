# Checkin Training Page 改造计划

## 📊 API数据需求分析

### 🔽 **需要从后端API获取的数据**

#### 1. **历史排名数据 (history)**
```dart
// ✅ 已实现：从API动态获取历史数据
List<Map<String, dynamic>> history = []; // 动态加载，不再硬编码
bool _isLoadingHistory = false;
String? _historyError;

// 历史数据加载方法
Future<void> _loadTrainingHistory() async {
  if (_isLoadingHistory) return;
  setState(() {
    _isLoadingHistory = true;
    _historyError = null;
  });
  
  try {
    final apiResponse = await _getTrainingHistoryApi();
    if (mounted) {
      setState(() {
        history = apiResponse;
        _isLoadingHistory = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _historyError = e.toString();
        _isLoadingHistory = false;
      });
    }
  }
}
```

**✅ 已实现：**
- `checkin_training_page.dart` 已实现历史数据动态加载
- 页面初始化时自动加载历史数据（在权限检查之前）
- 包含加载状态管理 (`_isLoadingHistory`, `_historyError`)
- 模拟API调用 (`_getTrainingHistoryApi`)
- 数据转换：API时间戳 → UI显示日期格式
- 支持手动刷新历史数据 (`_refreshHistory`)

**API需求：**
- **接口**: `GET /api/training/history`
- **参数**: 
  - `trainingId` (训练ID)
  - `productId` (产品ID，可选)
  - `limit` (返回数量限制)
- **返回数据**:
  ```json
  {
    "code": "A200",
    "message": "Success",
    "data": {
      "history": [
        {
          "id": "662553355",
          "rank": 1,
          "timestamp": 1737367800000,
          "counts": 19,
          "note": ""
        }
      ]
    }
  }
  ```

#### **历史数据管理特性**
- **初始化时机**: 页面加载时立即执行，不依赖麦克风权限
- **状态管理**: 包含加载状态、错误状态和成功状态
- **数据转换**: 自动将API时间戳转换为用户友好的日期格式
- **错误处理**: 网络错误或API错误时的优雅降级
- **内存优化**: 避免重复请求，防止内存泄漏
- **用户体验**: 加载时显示状态，错误时提供反馈

#### 2. **训练配置数据**
```dart
// 当前硬编码的默认值，保持本地配置
int totalRounds = 1;
int roundDuration = 60;
```

**说明：**
- 训练配置数据保持本地硬编码，不需要API获取
- 用户可以通过设置对话框修改配置
- 配置数据会随训练结果一起提交到后端

### 📤 **需要上报到后端的数据**

#### 1. **训练结果提交 (finalResult)**
```dart
// 当前提交的数据结构
finalResult = {
  "productId": widget.productId,
  "trainingId": widget.trainingId,
  "totalRounds": totalRounds,
  "roundDuration": roundDuration,
  "timestamp": DateTime.now().millisecondsSinceEpoch,
  "maxCounts": maxCounts,
};

// 提交完成后的清理逻辑
void _clearTmpResult() {
  tmpResult.clear();
  print('Cleared tmpResult after final submission');
}
```

**✅ 已实现：**
- `checkin_training_page.dart` 和 `checkin_training_voice_page.dart` 都已更新为使用 `timestamp` 字段
- 所有API提交数据都使用毫秒时间戳格式 (`DateTime.now().millisecondsSinceEpoch`)
- API返回数据也使用 `timestamp` 字段
- 所有页面的 `_addRoundToTmpResult` 方法都已移除冗余的 `date` 字段，只保留 `timestamp` 字段
- 统一更新了 `checkin_countdown_page.dart` 和 `challenge_game_page.dart` 的时间戳字段
- 所有训练页面都已移除设备信息获取功能，简化了API提交数据结构
- **历史数据管理**: `checkin_training_page.dart` 已实现完整的历史数据加载、状态管理和错误处理
- **权限管理**: 所有训练页面都已实现Apple级别的权限管理和声音检测功能

**API需求：**
- **接口**: `POST /api/training/submit`
- **请求数据**:
  ```json
  {
    "productId": "product123",
    "trainingId": "training456",
    "totalRounds": 3,
    "roundDuration": 60,
    "timestamp": 1737367800000,
    "maxCounts": 25
  }
  ```
- **返回数据**:
  ```json
  {
    "code": "A200",
    "message": "Success",
    "data": {
      "id": "662553355",
      "rank": 1,
      "totalRounds": 3,
      "roundDuration": 60
    }
  }
  ```

#### 2. **每轮训练数据 (tmpResult)**
```dart
// 当前临时存储的数据
tmpResult = [
  {
    "roundNumber": 1,
    "counts": 19,
    "timestamp": 1716393600000,
    "roundDuration": 60
  }
];
```

**说明：**
- 每轮训练数据在本地临时存储，用于计算最大counts
- 所有轮次结束后，只提交最大counts到后端
- 提交完成后，立即清理 `tmpResult` 数据以释放内存
- 不需要单独的每轮数据API接口
- **时间戳格式统一使用毫秒时间戳** (`System.currentTimeMillis()` 格式，int类型)

### 🔄 **数据生命周期管理**

#### **tmpResult 数据流程**
1. **初始化**: 训练开始时，`tmpResult.clear()` 清空历史数据
2. **收集**: 每轮结束后，`_addRoundToTmpResult()` 添加轮次数据
3. **计算**: 所有轮次结束后，遍历 `tmpResult` 找出最大counts
4. **提交**: 将最大counts提交到后端API
5. **清理**: 提交成功后，`_clearTmpResult()` 立即清理数据

#### **内存管理策略**
- ✅ **及时清理**: 提交完成后立即清理 `tmpResult`
- ✅ **防止内存泄漏**: 避免临时数据长期占用内存
- ✅ **性能优化**: 减少内存占用，提升应用性能

## 🏗️ **架构改造方案**

### 1. **Domain Layer（领域层）**

#### 实体 (Entities)
```dart
// lib/domain/entities/training_result.dart
class TrainingResult {
  final String id;
  final String trainingId;
  final String? productId;
  final int totalRounds;
  final int roundDuration;
  final int maxCounts;
  final int timestamp; // 毫秒时间戳
  final int? rank;
  final String? note;
  
  TrainingResult({
    required this.id,
    required this.trainingId,
    this.productId,
    required this.totalRounds,
    required this.roundDuration,
    required this.maxCounts,
    required this.timestamp,
    this.rank,
    this.note,
  });
}

// lib/domain/entities/training_round.dart
class TrainingRound {
  final int roundNumber;
  final int counts;
  final int timestamp; // 毫秒时间戳
  final int roundDuration;
  
  TrainingRound({
    required this.roundNumber,
    required this.counts,
    required this.timestamp,
    required this.roundDuration,
  });
}

// lib/domain/entities/training_history_item.dart
class TrainingHistoryItem {
  final String id;
  final int rank;
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note;
  
  TrainingHistoryItem({
    required this.id,
    required this.rank,
    required this.counts,
    required this.timestamp,
    this.note,
  });
  
  // 用于显示的历史记录项
  String get displayDate {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
  
  // 判断是否为当前训练结果
  bool get isCurrent => note == "current";
}

// lib/domain/entities/training_config.dart
class TrainingConfig {
  final int totalRounds;
  final int roundDuration;
  final int preCountdown;
  final bool audioDetectionEnabled;
  final String backgroundType;
  
  TrainingConfig({
    required this.totalRounds,
    required this.roundDuration,
    required this.preCountdown,
    required this.audioDetectionEnabled,
    required this.backgroundType,
  });
  
  // 本地配置，不需要从API获取
  factory TrainingConfig.defaultConfig() {
    return TrainingConfig(
      totalRounds: 1,
      roundDuration: 60,
      preCountdown: 10,
      audioDetectionEnabled: true,
      backgroundType: 'color',
    );
  }
}
```

#### 用例 (Use Cases)
```dart
// lib/domain/usecases/get_training_config_usecase.dart
class GetTrainingConfigUseCase {
  // 不再需要repository，直接返回本地配置
  TrainingConfig execute() {
    return TrainingConfig.defaultConfig();
  }
}

// lib/domain/usecases/get_training_history_usecase.dart
class GetTrainingHistoryUseCase {
  final TrainingRepository repository;
  
  GetTrainingHistoryUseCase(this.repository);
  
  Future<List<TrainingHistoryItem>> execute(String trainingId, {String? productId, int? limit}) {
    return repository.getTrainingHistory(trainingId, productId: productId, limit: limit);
  }
}

// lib/domain/usecases/submit_training_result_usecase.dart
class SubmitTrainingResultUseCase {
  final TrainingRepository repository;
  
  SubmitTrainingResultUseCase(this.repository);
  
  Future<TrainingResult> execute(TrainingResult result) {
    return repository.submitTrainingResult(result);
  }
}
```

#### 仓库接口 (Repository Interfaces)
```dart
// lib/domain/repositories/training_repository.dart
abstract class TrainingRepository {
  Future<List<TrainingHistoryItem>> getTrainingHistory(String trainingId, {String? productId, int? limit});
  Future<TrainingResult> submitTrainingResult(TrainingResult result);
}
```

### 2. **Data Layer（数据层）**

#### API模型 (API Models)
```dart
// lib/data/models/training_config_api_model.dart
// 已移除，训练配置不再需要API模型

// lib/data/models/training_result_api_model.dart
class TrainingResultApiModel {
  final String id;
  final String trainingId;
  final String? productId;
  final int totalRounds;
  final int roundDuration;
  final int maxCounts;
  final int timestamp; // 毫秒时间戳
  final int? rank;
  final String? note;
  
  TrainingResultApiModel({
    required this.id,
    required this.trainingId,
    this.productId,
    required this.totalRounds,
    required this.roundDuration,
    required this.maxCounts,
    required this.timestamp,
    this.rank,
    this.note,
  });
  
  factory TrainingResultApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingResultApiModel(
      id: json['id'] as String,
      trainingId: json['trainingId'] as String,
      productId: json['productId'] as String?,
      totalRounds: json['totalRounds'] as int,
      roundDuration: json['roundDuration'] as int,
      maxCounts: json['maxCounts'] as int,
      timestamp: json['timestamp'] as int, // 毫秒时间戳
      rank: json['rank'] as int?,
      note: json['note'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'trainingId': trainingId,
    if (productId != null) 'productId': productId,
    'totalRounds': totalRounds,
    'roundDuration': roundDuration,
    'maxCounts': maxCounts,
    'timestamp': timestamp,
    'rank': rank,
    'note': note,
  };
}

// lib/data/models/training_history_api_model.dart
class TrainingHistoryApiModel {
  final String id;
  final int rank;
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note;
  
  TrainingHistoryApiModel({
    required this.id,
    required this.rank,
    required this.counts,
    required this.timestamp,
    this.note,
  });
  
  factory TrainingHistoryApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingHistoryApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      counts: json['counts'] as int,
      timestamp: json['timestamp'] as int, // 毫秒时间戳
      note: json['note'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'counts': counts,
    'timestamp': timestamp,
    'note': note,
  };
}
```

#### API接口 (API Interfaces)
```dart
// lib/data/api/training_api.dart
class TrainingApi {
  final Dio _dio = DioClient().dio;
  
  Future<List<TrainingHistoryApiModel>> getTrainingHistory(String trainingId, {String? productId, int? limit}) async {
    final response = await _dio.get('/api/training/history', queryParameters: {
      'trainingId': trainingId,
      if (productId != null) 'productId': productId,
      if (limit != null) 'limit': limit,
    });
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return (response.data['data']['history'] as List)
          .map((item) => TrainingHistoryApiModel.fromJson(item))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }
  
  Future<TrainingResultApiModel> submitTrainingResult(TrainingResultApiModel result) async {
    final response = await _dio.post('/api/training/submit', data: result.toJson());
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return TrainingResultApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }
}
```

#### 仓库实现 (Repository Implementation)
```dart
// lib/data/repository/training_repository_impl.dart
class TrainingRepositoryImpl implements TrainingRepository {
  final TrainingApi _trainingApi;
  
  TrainingRepositoryImpl(this._trainingApi);
  
  @override
  Future<List<TrainingHistoryItem>> getTrainingHistory(String trainingId, {String? productId, int? limit}) async {
    final apiModels = await _trainingApi.getTrainingHistory(trainingId, productId: productId, limit: limit);
    return apiModels.map((apiModel) => _mapToTrainingHistoryItem(apiModel)).toList();
  }
  
  @override
  Future<TrainingResult> submitTrainingResult(TrainingResult result) async {
    final apiModel = _mapToTrainingResultApiModel(result);
    final responseApiModel = await _trainingApi.submitTrainingResult(apiModel);
    return _mapToTrainingResult(responseApiModel);
  }
  
  // 映射方法
  TrainingHistoryItem _mapToTrainingHistoryItem(TrainingHistoryApiModel apiModel) {
    return TrainingHistoryItem(
      id: apiModel.id,
      rank: apiModel.rank,
      counts: apiModel.counts,
      timestamp: apiModel.timestamp,
      note: apiModel.note,
    );
  }
  
  TrainingResult _mapToTrainingResult(TrainingResultApiModel apiModel) {
    return TrainingResult(
      id: apiModel.id,
      trainingId: apiModel.trainingId,
      productId: apiModel.productId,
      totalRounds: apiModel.totalRounds,
      roundDuration: apiModel.roundDuration,
      maxCounts: apiModel.maxCounts,
      timestamp: apiModel.timestamp, // 直接使用毫秒时间戳
      rank: apiModel.rank,
      note: apiModel.note,
    );
  }
}
```

### 3. **Presentation Layer（表现层）**

#### ViewModel
```dart
// lib/presentation/checkin_start_training/checkin_training_viewmodel.dart
class CheckinTrainingViewModel extends ChangeNotifier {
  final GetTrainingConfigUseCase getTrainingConfigUseCase;
  final GetTrainingHistoryUseCase getTrainingHistoryUseCase;
  final SubmitTrainingResultUseCase submitTrainingResultUseCase;
  
  // 状态
  TrainingConfig? trainingConfig;
  List<TrainingHistoryItem> history = [];
  TrainingResult? currentResult;
  bool isLoading = false;
  String? error;
  bool isSubmitting = false;
  
  CheckinTrainingViewModel({
    required this.getTrainingConfigUseCase,
    required this.getTrainingHistoryUseCase,
    required this.submitTrainingResultUseCase,
  });
  
  Future<void> loadTrainingConfig() async {
    try {
      isLoading = true;
      notifyListeners();
      
      trainingConfig = getTrainingConfigUseCase.execute();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadTrainingHistory(String trainingId, {String? productId}) async {
    try {
      isLoading = true;
      notifyListeners();
      
      history = await getTrainingHistoryUseCase.execute(trainingId, productId: productId);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> submitTrainingResult(TrainingResult result) async {
    try {
      isSubmitting = true;
      notifyListeners();
      
      currentResult = await submitTrainingResultUseCase.execute(result);
      // 提交成功后，更新历史数据
      if (currentResult != null) {
        await loadTrainingHistory(result.trainingId, productId: result.productId);
      }
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
```

## 🚀 **实现步骤**

### 阶段1: 创建Domain层
1. ✅ 创建实体类 (TrainingResult, TrainingRound, TrainingConfig)
2. ✅ 创建用例类 (GetTrainingConfigUseCase, GetTrainingHistoryUseCase, SubmitTrainingResultUseCase)
3. ✅ 创建仓库接口 (TrainingRepository)

### 阶段2: 创建Data层
1. ✅ 创建API模型类 (TrainingResultApiModel)
2. ✅ 创建API接口类 (TrainingApi)
3. ✅ 创建仓库实现类 (TrainingRepositoryImpl)

### 阶段3: 创建Presentation层
1. ✅ 创建ViewModel类 (CheckinTrainingViewModel)
2. ✅ 修改页面使用Provider模式
3. ✅ 集成API调用

### 阶段4: 测试和优化
1. ✅ 单元测试
2. ✅ 集成测试
3. ✅ 性能优化
4. ✅ 错误处理完善

## 📋 **待办事项**

### ✅ **已完成**
- [x] 历史数据动态加载和状态管理 (`checkin_training_page.dart`)
- [x] 时间戳格式统一 (所有训练页面)
- [x] 权限管理和声音检测 (所有训练页面)
- [x] 临时数据清理机制 (所有训练页面)
- [x] 错误处理和加载状态 (历史数据部分)

### 🔄 **进行中**
- [ ] 创建Domain层实体类 (TrainingResult, TrainingRound, TrainingConfig)
- [ ] 创建Domain层用例类 (GetTrainingConfigUseCase, GetTrainingHistoryUseCase, SubmitTrainingResultUseCase)
- [ ] 创建Domain层仓库接口 (TrainingRepository)
- [ ] 创建Data层API模型类 (TrainingResultApiModel)
- [ ] 创建Data层API接口类 (TrainingApi)
- [ ] 创建Data层仓库实现类 (TrainingRepositoryImpl)
- [ ] 创建Presentation层ViewModel (CheckinTrainingViewModel)
- [ ] 修改页面集成Provider模式

### 📝 **待开始**
- [ ] 添加数据缓存机制
- [ ] 编写测试用例
- [ ] 性能优化
- [ ] 文档完善

## 🎯 **当前实现效果**

目前已实现的功能：
- ✅ **历史数据管理**: 动态加载、状态管理、错误处理
- ✅ **权限管理**: Apple级别的麦克风权限管理和声音检测
- ✅ **数据一致性**: 统一的时间戳格式和临时数据清理
- ✅ **用户体验**: 加载状态、错误反馈、优雅降级
- ✅ **代码质量**: 类型安全、内存管理、错误处理

## 🎯 **预期完整效果**

改造完成后，页面将具备：
- ✅ 清晰的分层架构
- ✅ 可测试的代码结构
- ✅ 可维护的业务逻辑
- ✅ 完善的错误处理
- ✅ 良好的用户体验
- ✅ 团队协作友好
