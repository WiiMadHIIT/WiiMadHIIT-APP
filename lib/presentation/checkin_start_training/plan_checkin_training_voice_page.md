# Checkin Training Voice Page 改造计划

## 📊 API数据需求分析

### 🔽 **需要从后端API获取的数据**

#### 1. **历史排名数据 (history)**
```dart
// ✅ 已实现：从API动态获取历史数据
List<Map<String, dynamic>> history = []; // 动态加载，不再硬编码
bool _isLoadingHistory = false;
String? _historyError;

// 历史数据和视频配置加载方法
Future<void> _loadTrainingDataAndVideoConfig() async {
  if (_isLoadingHistory || _isLoadingVideoConfig) return;
  setState(() {
    _isLoadingHistory = true;
    _isLoadingVideoConfig = true;
    _historyError = null;
    _videoConfigError = null;
  });
  
  try {
    final apiResponse = await _getTrainingDataAndVideoConfigApi();
    if (mounted) {
      setState(() {
        history = apiResponse['history'];
        _portraitVideoUrl = apiResponse['videoConfig']['portraitUrl'];
        _landscapeVideoUrl = apiResponse['videoConfig']['landscapeUrl'];
        _isLoadingHistory = false;
        _isLoadingVideoConfig = false;
      });
      
      // 根据当前屏幕方向初始化视频
      await _initializeVideoBasedOnOrientation();
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _historyError = e.toString();
        _videoConfigError = e.toString();
        _isLoadingHistory = false;
        _isLoadingVideoConfig = false;
      });
      
      // 使用默认视频配置
      await _initializeDefaultVideo();
    }
  }
}
```

**✅ 已实现：**
- `checkin_training_voice_page.dart` 已实现历史数据和视频配置动态加载
- 页面初始化时自动加载历史数据和视频配置（在权限检查之前）
- 包含加载状态管理 (`_isLoadingHistory`, `_historyError`, `_isLoadingVideoConfig`, `_videoConfigError`)
- 模拟API调用 (`_getTrainingDataAndVideoConfigApi`)
- 数据转换：API时间戳 → UI显示日期格式
- 支持手动刷新历史数据 (`_refreshHistory`)
- 视频配置：支持远程视频URL和本地回退机制
- 方向适配：自动根据屏幕方向切换视频

**API需求：**
- **接口**: `GET /api/voice-training/data`
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
      ],
      "videoConfig": {
        "portraitUrl": "https://example.com/videos/voice_training_portrait.mp4",
        "landscapeUrl": "https://example.com/videos/voice_training_landscape.mp4"
      }
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

#### **视频配置管理特性**
- **统一获取**: 与历史数据一起作为一次API请求获取
- **方向适配**: 支持横屏和竖屏不同的视频URL
- **远程优先**: 优先使用远程视频URL，失败时回退到本地视频
- **自动回退**: 远程视频失败时自动使用本地默认视频
- **方向监听**: 屏幕方向改变时自动切换对应的视频
- **错误处理**: 多层回退机制确保视频始终可用

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

#### 3. **视频配置数据**
```dart
// 从API获取的视频配置
String? _portraitVideoUrl; // 竖屏视频URL
String? _landscapeVideoUrl; // 横屏视频URL
bool _isLoadingVideoConfig = false; // 视频配置加载状态
String? _videoConfigError; // 视频配置错误
```

**说明：**
- 视频配置数据从API获取，支持远程视频URL
- 支持横屏和竖屏不同的视频URL
- 如果远程视频获取失败，自动回退到本地默认视频
- 默认本地视频：竖屏 `assets/video/video1.mp4`，横屏 `assets/video/video2.mp4`

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
- `checkin_training_voice_page.dart` 已更新为使用 `timestamp` 字段
- 所有API提交数据都使用毫秒时间戳格式 (`DateTime.now().millisecondsSinceEpoch`)
- API返回数据也使用 `timestamp` 字段
- 页面的 `_addRoundToTmpResult` 方法已移除冗余的 `date` 字段，只保留 `timestamp` 字段
- **历史数据管理**: `checkin_training_voice_page.dart` 已实现完整的历史数据加载、状态管理和错误处理
- **权限管理**: 已实现Apple级别的权限管理和声音检测功能
- **语音检测集成**: 完整的语音检测初始化、启动、停止和清理流程

**API需求：**
- **接口**: `POST /api/training/voice/submit`
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

### 🎤 **语音检测功能特性**

#### **Apple级别的权限管理**
```dart
// 权限检查和管理
Future<bool> _requestMicrophonePermissionDirectly() async {
  // 1. 检查当前权限状态
  // 2. 权限已授予，直接初始化音频检测
  // 3. 权限被永久拒绝，显示设置指导
  // 4. 权限未授予，直接请求权限
  // 5. 等待用户响应系统权限弹窗
  // 6. 再次检查权限状态
  // 7. 根据最终状态执行相应操作
}

// 权限状态监听
void _startPermissionListener() {
  // 每3秒检查一次权限状态
  // 权限授予时自动初始化音频检测
  // 权限被拒绝时显示设置指导
}
```

#### **语音检测生命周期管理**
```dart
// 初始化语音检测
Future<void> _initializeVoiceDetection() async {
  // 1. 创建流音频检测器实例
  // 2. 设置检测回调
  // 3. 设置错误回调
  // 4. 设置状态回调
  // 5. 初始化流音频检测器
}

// 训练开始时启动语音检测
Future<void> _startVoiceDetectionForRound() async {
  // 启动语音检测
  // 提供用户反馈
  // 错误处理
}

// 训练结束时停止语音检测
Future<void> _stopVoiceDetectionForRound() async {
  // 停止语音检测
  // 状态检查
  // 错误处理
}
```

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
- ✅ **资源管理**: 语音检测资源的正确初始化和清理

## 🏗️ **架构改造方案**

### 1. **Domain Layer（领域层）**

#### 实体 (Entities)
```dart
// lib/domain/entities/voice_training_result.dart
class VoiceTrainingResult {
  final String id;
  final String trainingId;
  final String? productId;
  final int totalRounds;
  final int roundDuration;
  final int maxCounts;
  final int timestamp; // 毫秒时间戳
  
  VoiceTrainingResult({
    required this.id,
    required this.trainingId,
    this.productId,
    required this.totalRounds,
    required this.roundDuration,
    required this.maxCounts,
    required this.timestamp,
  });
}

// lib/domain/entities/voice_training_round.dart
class VoiceTrainingRound {
  final int roundNumber;
  final int counts;
  final int timestamp; // 毫秒时间戳
  final int roundDuration;
  
  VoiceTrainingRound({
    required this.roundNumber,
    required this.counts,
    required this.timestamp,
    required this.roundDuration,
  });
}

// lib/domain/entities/voice_training_history_item.dart
class VoiceTrainingHistoryItem {
  final String id;
  final int? rank; // 可为null，表示正在加载
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note; // 用于标识当前训练结果
  
  VoiceTrainingHistoryItem({
    required this.id,
    this.rank, // 可为null
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
  
  // 判断是否正在加载排名
  bool get isLoadingRank => rank == null && isCurrent;
}

// lib/domain/entities/voice_training_config.dart
class VoiceTrainingConfig {
  final int totalRounds;
  final int roundDuration;
  final int preCountdown;
  final bool audioDetectionEnabled;
  final String backgroundType;
  
  VoiceTrainingConfig({
    required this.totalRounds,
    required this.roundDuration,
    required this.preCountdown,
    required this.audioDetectionEnabled,
    required this.backgroundType,
  });
  
  // 本地配置，不需要从API获取
  factory VoiceTrainingConfig.defaultConfig() {
    return VoiceTrainingConfig(
      totalRounds: 1,
      roundDuration: 60,
      preCountdown: 10,
      audioDetectionEnabled: true, // 语音训练默认开启
      backgroundType: 'color',
    );
  }
}

// lib/domain/entities/voice_detection_config.dart
class VoiceDetectionConfig {
  final bool enabled;
  final double sensitivity;
  final int debounceTime;
  final String audioSource;
  
  VoiceDetectionConfig({
    required this.enabled,
    required this.sensitivity,
    required this.debounceTime,
    required this.audioSource,
  });
  
  factory VoiceDetectionConfig.defaultConfig() {
    return VoiceDetectionConfig(
      enabled: true,
      sensitivity: 0.5,
      debounceTime: 200,
      audioSource: 'microphone',
    );
  }
}
```

#### 用例 (Use Cases)
```dart
// lib/domain/usecases/get_voice_training_config_usecase.dart
class GetVoiceTrainingConfigUseCase {
  // 不再需要repository，直接返回本地配置
  VoiceTrainingConfig execute() {
    return VoiceTrainingConfig.defaultConfig();
  }
}

// lib/domain/usecases/get_voice_detection_config_usecase.dart
class GetVoiceDetectionConfigUseCase {
  VoiceDetectionConfig execute() {
    return VoiceDetectionConfig.defaultConfig();
  }
}

// lib/domain/usecases/get_voice_training_history_usecase.dart
class GetVoiceTrainingHistoryUseCase {
  final VoiceTrainingRepository repository;
  
  GetVoiceTrainingHistoryUseCase(this.repository);
  
  Future<List<VoiceTrainingHistoryItem>> execute(String trainingId, {String? productId, int? limit}) {
    return repository.getVoiceTrainingHistory(trainingId, productId: productId, limit: limit);
  }
}

// lib/domain/usecases/submit_voice_training_result_usecase.dart
class SubmitVoiceTrainingResultUseCase {
  final VoiceTrainingRepository repository;
  
  SubmitVoiceTrainingResultUseCase(this.repository);
  
  Future<VoiceTrainingSubmitResponseApiModel> execute(VoiceTrainingResult result) {
    return repository.submitVoiceTrainingResult(result);
  }
}

// lib/domain/usecases/initialize_voice_detection_usecase.dart
class InitializeVoiceDetectionUseCase {
  final VoiceDetectionService voiceDetectionService;
  
  InitializeVoiceDetectionUseCase(this.voiceDetectionService);
  
  Future<bool> execute(VoiceDetectionConfig config) {
    return voiceDetectionService.initialize(config);
  }
}

// lib/domain/usecases/start_voice_detection_usecase.dart
class StartVoiceDetectionUseCase {
  final VoiceDetectionService voiceDetectionService;
  
  StartVoiceDetectionUseCase(this.voiceDetectionService);
  
  Future<bool> execute() {
    return voiceDetectionService.startListening();
  }
}

// lib/domain/usecases/stop_voice_detection_usecase.dart
class StopVoiceDetectionUseCase {
  final VoiceDetectionService voiceDetectionService;
  
  StopVoiceDetectionUseCase(this.voiceDetectionService);
  
  Future<void> execute() {
    return voiceDetectionService.stopListening();
  }
}
```

#### 仓库接口 (Repository Interfaces)
```dart
// lib/domain/repositories/voice_training_repository.dart
abstract class VoiceTrainingRepository {
  Future<List<VoiceTrainingHistoryItem>> getVoiceTrainingHistory(String trainingId, {String? productId, int? limit});
  Future<VoiceTrainingSubmitResponseApiModel> submitVoiceTrainingResult(VoiceTrainingResult result);
}

// lib/domain/repositories/voice_detection_repository.dart
abstract class VoiceDetectionRepository {
  Future<bool> checkMicrophonePermission();
  Future<bool> requestMicrophonePermission();
  Future<void> openAppSettings();
}
```

#### 服务接口 (Service Interfaces)
```dart
// lib/domain/services/voice_detection_service.dart
abstract class VoiceDetectionService {
  Future<bool> initialize(VoiceDetectionConfig config);
  Future<bool> startListening();
  Future<void> stopListening();
  Future<void> dispose();
  
  // 回调设置
  void setOnStrikeDetected(VoidCallback callback);
  void setOnError(Function(String) callback);
  void setOnStatusUpdate(Function(String) callback);
  
  // 状态查询
  bool get isListening;
  bool get isInitialized;
}
```

### 2. **Data Layer（数据层）**

#### API模型 (API Models)
```dart
// lib/data/models/voice_training_result_api_model.dart
class VoiceTrainingResultApiModel {
  final String id;
  final String trainingId;
  final String? productId;
  final int totalRounds;
  final int roundDuration;
  final int maxCounts;
  final int timestamp; // 毫秒时间戳
  
  VoiceTrainingResultApiModel({
    required this.id,
    required this.trainingId,
    this.productId,
    required this.totalRounds,
    required this.roundDuration,
    required this.maxCounts,
    required this.timestamp,
  });
  
  factory VoiceTrainingResultApiModel.fromJson(Map<String, dynamic> json) {
    return VoiceTrainingResultApiModel(
      id: json['id'] as String,
      trainingId: json['trainingId'] as String,
      productId: json['productId'] as String?,
      totalRounds: json['totalRounds'] as int,
      roundDuration: json['roundDuration'] as int,
      maxCounts: json['maxCounts'] as int,
      timestamp: json['timestamp'] as int, // 毫秒时间戳
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
  };
}

// lib/data/models/voice_training_submit_response_api_model.dart
class VoiceTrainingSubmitResponseApiModel {
  final String id;
  final int rank;
  final int totalRounds;
  final int roundDuration;
  
  VoiceTrainingSubmitResponseApiModel({
    required this.id,
    required this.rank,
    required this.totalRounds,
    required this.roundDuration,
  });
  
  factory VoiceTrainingSubmitResponseApiModel.fromJson(Map<String, dynamic> json) {
    return VoiceTrainingSubmitResponseApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      totalRounds: json['totalRounds'] as int,
      roundDuration: json['roundDuration'] as int,
    );
  }
}

// lib/data/models/voice_training_history_api_model.dart
class VoiceTrainingHistoryApiModel {
  final String id;
  final int rank;
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note;
  
  VoiceTrainingHistoryApiModel({
    required this.id,
    required this.rank,
    required this.counts,
    required this.timestamp,
    this.note,
  });
  
  factory VoiceTrainingHistoryApiModel.fromJson(Map<String, dynamic> json) {
    return VoiceTrainingHistoryApiModel(
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
// lib/data/api/voice_training_api.dart
class VoiceTrainingApi {
  final Dio _dio = DioClient().dio;
  
  Future<List<VoiceTrainingHistoryApiModel>> getVoiceTrainingHistory(String trainingId, {String? productId, int? limit}) async {
    final response = await _dio.get('/api/voice-training/history', queryParameters: {
      'trainingId': trainingId,
      if (productId != null) 'productId': productId,
      if (limit != null) 'limit': limit,
    });
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return (response.data['data']['history'] as List)
          .map((item) => VoiceTrainingHistoryApiModel.fromJson(item))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }
  
  Future<VoiceTrainingSubmitResponseApiModel> submitVoiceTrainingResult(VoiceTrainingResultApiModel result) async {
    final response = await _dio.post('/api/voice-training/submit', data: result.toJson());
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return VoiceTrainingSubmitResponseApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }
}
```

#### 仓库实现 (Repository Implementation)
```dart
// lib/data/repository/voice_training_repository_impl.dart
class VoiceTrainingRepositoryImpl implements VoiceTrainingRepository {
  final VoiceTrainingApi _voiceTrainingApi;
  
  VoiceTrainingRepositoryImpl(this._voiceTrainingApi);
  
  @override
  Future<List<VoiceTrainingHistoryItem>> getVoiceTrainingHistory(String trainingId, {String? productId, int? limit}) async {
    final apiModels = await _voiceTrainingApi.getVoiceTrainingHistory(trainingId, productId: productId, limit: limit);
    return apiModels.map((apiModel) => _mapToVoiceTrainingHistoryItem(apiModel)).toList();
  }
  
  @override
  Future<VoiceTrainingSubmitResponseApiModel> submitVoiceTrainingResult(VoiceTrainingResult result) async {
    final apiModel = _mapToVoiceTrainingResultApiModel(result);
    return await _voiceTrainingApi.submitVoiceTrainingResult(apiModel);
  }
  
  // 映射方法
  VoiceTrainingHistoryItem _mapToVoiceTrainingHistoryItem(VoiceTrainingHistoryApiModel apiModel) {
    return VoiceTrainingHistoryItem(
      id: apiModel.id,
      rank: apiModel.rank,
      counts: apiModel.counts,
      timestamp: apiModel.timestamp,
      note: apiModel.note,
    );
  }
  
  VoiceTrainingResult _mapToVoiceTrainingResult(VoiceTrainingResultApiModel apiModel) {
    return VoiceTrainingResult(
      id: apiModel.id,
      trainingId: apiModel.trainingId,
      productId: apiModel.productId,
      totalRounds: apiModel.totalRounds,
      roundDuration: apiModel.roundDuration,
      maxCounts: apiModel.maxCounts,
      timestamp: apiModel.timestamp, // 直接使用毫秒时间戳
    );
  }
  
  VoiceTrainingResultApiModel _mapToVoiceTrainingResultApiModel(VoiceTrainingResult result) {
    return VoiceTrainingResultApiModel(
      id: result.id,
      trainingId: result.trainingId,
      productId: result.productId,
      totalRounds: result.totalRounds,
      roundDuration: result.roundDuration,
      maxCounts: result.maxCounts,
      timestamp: result.timestamp,
    );
  }
}

// lib/data/repository/voice_detection_repository_impl.dart
class VoiceDetectionRepositoryImpl implements VoiceDetectionRepository {
  @override
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  @override
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  @override
  Future<void> openAppSettings() async {
    await AppSettings.openAppSettings();
  }
}
```

#### 服务实现 (Service Implementation)
```dart
// lib/data/services/voice_detection_service_impl.dart
class VoiceDetectionServiceImpl implements VoiceDetectionService {
  StreamAudioDetector? _audioDetector;
  VoiceDetectionConfig? _config;
  VoidCallback? _onStrikeDetected;
  Function(String)? _onError;
  Function(String)? _onStatusUpdate;
  
  @override
  Future<bool> initialize(VoiceDetectionConfig config) async {
    try {
      _config = config;
      _audioDetector ??= StreamAudioDetector();
      
      // 设置回调
      if (_onStrikeDetected != null) {
        _audioDetector!.onStrikeDetected = _onStrikeDetected!;
      }
      if (_onError != null) {
        _audioDetector!.onError = _onError!;
      }
      if (_onStatusUpdate != null) {
        _audioDetector!.onStatusUpdate = _onStatusUpdate!;
      }
      
      final success = await _audioDetector!.initialize();
      return success;
    } catch (e) {
      print('Voice detection initialization error: $e');
      return false;
    }
  }
  
  @override
  Future<bool> startListening() async {
    try {
      if (_audioDetector == null) return false;
      return await _audioDetector!.startListening();
    } catch (e) {
      print('Voice detection start error: $e');
      return false;
    }
  }
  
  @override
  Future<void> stopListening() async {
    try {
      if (_audioDetector != null && _audioDetector!.isListening) {
        await _audioDetector!.stopListening();
      }
    } catch (e) {
      print('Voice detection stop error: $e');
    }
  }
  
  @override
  Future<void> dispose() async {
    try {
      await stopListening();
      _audioDetector?.dispose();
      _audioDetector = null;
    } catch (e) {
      print('Voice detection dispose error: $e');
    }
  }
  
  @override
  void setOnStrikeDetected(VoidCallback callback) {
    _onStrikeDetected = callback;
    if (_audioDetector != null) {
      _audioDetector!.onStrikeDetected = callback;
    }
  }
  
  @override
  void setOnError(Function(String) callback) {
    _onError = callback;
    if (_audioDetector != null) {
      _audioDetector!.onError = callback;
    }
  }
  
  @override
  void setOnStatusUpdate(Function(String) callback) {
    _onStatusUpdate = callback;
    if (_audioDetector != null) {
      _audioDetector!.onStatusUpdate = callback;
    }
  }
  
  @override
  bool get isListening => _audioDetector?.isListening ?? false;
  
  @override
  bool get isInitialized => _audioDetector != null;
}
```

### 3. **Presentation Layer（表现层）**

#### ViewModel
```dart
// lib/presentation/checkin_start_training/checkin_training_voice_viewmodel.dart
class CheckinTrainingVoiceViewModel extends ChangeNotifier {
  final GetVoiceTrainingConfigUseCase getVoiceTrainingConfigUseCase;
  final GetVoiceDetectionConfigUseCase getVoiceDetectionConfigUseCase;
  final GetVoiceTrainingHistoryUseCase getVoiceTrainingHistoryUseCase;
  final SubmitVoiceTrainingResultUseCase submitVoiceTrainingResultUseCase;
  final InitializeVoiceDetectionUseCase initializeVoiceDetectionUseCase;
  final StartVoiceDetectionUseCase startVoiceDetectionUseCase;
  final StopVoiceDetectionUseCase stopVoiceDetectionUseCase;
  final VoiceDetectionRepository voiceDetectionRepository;
  
  // 状态
  VoiceTrainingConfig? voiceTrainingConfig;
  VoiceDetectionConfig? voiceDetectionConfig;
  List<VoiceTrainingHistoryItem> history = [];
  VoiceTrainingResult? currentResult;
  bool isLoading = false;
  String? error;
  bool isSubmitting = false;
  
  // 语音检测状态
  bool isVoiceDetectionInitialized = false;
  bool isVoiceDetectionListening = false;
  bool isVoiceDetectionEnabled = true;
  String? voiceDetectionError;
  
  CheckinTrainingVoiceViewModel({
    required this.getVoiceTrainingConfigUseCase,
    required this.getVoiceDetectionConfigUseCase,
    required this.getVoiceTrainingHistoryUseCase,
    required this.submitVoiceTrainingResultUseCase,
    required this.initializeVoiceDetectionUseCase,
    required this.startVoiceDetectionUseCase,
    required this.stopVoiceDetectionUseCase,
    required this.voiceDetectionRepository,
  });
  
  Future<void> loadVoiceTrainingConfig() async {
    try {
      isLoading = true;
      notifyListeners();
      
      voiceTrainingConfig = getVoiceTrainingConfigUseCase.execute();
      voiceDetectionConfig = getVoiceDetectionConfigUseCase.execute();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadVoiceTrainingHistory(String trainingId, {String? productId}) async {
    try {
      isLoading = true;
      notifyListeners();
      
      history = await getVoiceTrainingHistoryUseCase.execute(trainingId, productId: productId);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> submitVoiceTrainingResult(VoiceTrainingResult result) async {
    try {
      isSubmitting = true;
      notifyListeners();
      
      final response = await submitVoiceTrainingResultUseCase.execute(result);
      // 提交成功后，更新历史数据
      await loadVoiceTrainingHistory(result.trainingId, productId: result.productId);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
  
  Future<bool> initializeVoiceDetection() async {
    try {
      if (voiceDetectionConfig == null) {
        voiceDetectionConfig = getVoiceDetectionConfigUseCase.execute();
      }
      
      final success = await initializeVoiceDetectionUseCase.execute(voiceDetectionConfig!);
      isVoiceDetectionInitialized = success;
      voiceDetectionError = success ? null : 'Failed to initialize voice detection';
      notifyListeners();
      return success;
    } catch (e) {
      voiceDetectionError = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> startVoiceDetection() async {
    try {
      if (!isVoiceDetectionInitialized) {
        final initialized = await initializeVoiceDetection();
        if (!initialized) return false;
      }
      
      final success = await startVoiceDetectionUseCase.execute();
      isVoiceDetectionListening = success;
      voiceDetectionError = success ? null : 'Failed to start voice detection';
      notifyListeners();
      return success;
    } catch (e) {
      voiceDetectionError = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> stopVoiceDetection() async {
    try {
      await stopVoiceDetectionUseCase.execute();
      isVoiceDetectionListening = false;
      voiceDetectionError = null;
      notifyListeners();
    } catch (e) {
      voiceDetectionError = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> checkMicrophonePermission() async {
    return await voiceDetectionRepository.checkMicrophonePermission();
  }
  
  Future<bool> requestMicrophonePermission() async {
    return await voiceDetectionRepository.requestMicrophonePermission();
  }
  
  Future<void> openAppSettings() async {
    await voiceDetectionRepository.openAppSettings();
  }
}
```

## 🚀 **实现步骤**

### 阶段1: 创建Domain层
1. ✅ 创建实体类 (VoiceTrainingResult, VoiceTrainingRound, VoiceTrainingConfig, VoiceDetectionConfig)
2. ✅ 创建用例类 (GetVoiceTrainingConfigUseCase, GetVoiceDetectionConfigUseCase, GetVoiceTrainingHistoryUseCase, SubmitVoiceTrainingResultUseCase, InitializeVoiceDetectionUseCase, StartVoiceDetectionUseCase, StopVoiceDetectionUseCase)
3. ✅ 创建仓库接口 (VoiceTrainingRepository, VoiceDetectionRepository)
4. ✅ 创建服务接口 (VoiceDetectionService)

### 阶段2: 创建Data层
1. ✅ 创建API模型类 (VoiceTrainingResultApiModel, VoiceTrainingSubmitResponseApiModel, VoiceTrainingHistoryApiModel)
2. ✅ 创建API接口类 (VoiceTrainingApi)
3. ✅ 创建仓库实现类 (VoiceTrainingRepositoryImpl, VoiceDetectionRepositoryImpl)
4. ✅ 创建服务实现类 (VoiceDetectionServiceImpl)

### 阶段3: 创建Presentation层
1. ✅ 创建ViewModel类 (CheckinTrainingVoiceViewModel)
2. ✅ 修改页面使用Provider模式
3. ✅ 集成API调用和语音检测服务

### 阶段4: 测试和优化
1. ✅ 单元测试
2. ✅ 集成测试
3. ✅ 性能优化
4. ✅ 错误处理完善

## 📋 **待办事项**

### ✅ **已完成**
- [x] 历史数据动态加载和状态管理 (`checkin_training_voice_page.dart`)
- [x] 时间戳格式统一 (语音训练页面)
- [x] 权限管理和声音检测 (Apple级别实现)
- [x] 临时数据清理机制 (语音训练页面)
- [x] 错误处理和加载状态 (历史数据部分)
- [x] 语音检测生命周期管理 (初始化、启动、停止、清理)

### 🔄 **进行中**
- [ ] 创建Domain层实体类 (VoiceTrainingResult, VoiceTrainingRound, VoiceTrainingConfig, VoiceDetectionConfig)
- [ ] 创建Domain层用例类 (GetVoiceTrainingConfigUseCase, GetVoiceDetectionConfigUseCase, GetVoiceTrainingHistoryUseCase, SubmitVoiceTrainingResultUseCase, InitializeVoiceDetectionUseCase, StartVoiceDetectionUseCase, StopVoiceDetectionUseCase)
- [ ] 创建Domain层仓库接口 (VoiceTrainingRepository, VoiceDetectionRepository)
- [ ] 创建Domain层服务接口 (VoiceDetectionService)
- [ ] 创建Data层API模型类 (VoiceTrainingResultApiModel, VoiceTrainingSubmitResponseApiModel, VoiceTrainingHistoryApiModel)
- [ ] 创建Data层API接口类 (VoiceTrainingApi)
- [ ] 创建Data层仓库实现类 (VoiceTrainingRepositoryImpl, VoiceDetectionRepositoryImpl)
- [ ] 创建Data层服务实现类 (VoiceDetectionServiceImpl)
- [ ] 创建Presentation层ViewModel (CheckinTrainingVoiceViewModel)
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
- ✅ **语音检测**: 完整的语音检测功能集成

## 🎯 **预期完整效果**

改造完成后，页面将具备：
- ✅ 清晰的分层架构
- ✅ 可测试的代码结构
- ✅ 可维护的业务逻辑
- ✅ 完善的错误处理
- ✅ 良好的用户体验
- ✅ 团队协作友好
- ✅ 语音检测功能完整集成
