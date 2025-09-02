import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/usecases/get_training_voice_data_and_video_config_usecase.dart';
import '../../domain/services/training_voice_service.dart';
import '../../domain/entities/checkin_training_voice/training_voice_history_item.dart';
import '../../domain/entities/checkin_training_voice/training_voice_result.dart';
import '../../data/models/checkin_training_voice_api_model.dart';

/// 语音训练页面 ViewModel
class CheckinTrainingVoiceViewModel extends ChangeNotifier {
  // 用例依赖
  final GetTrainingVoiceDataAndVideoConfigUseCase _getTrainingVoiceDataAndVideoConfigUseCase;
  final GetTrainingVoiceHistoryUseCase _getTrainingVoiceHistoryUseCase;
  final SubmitTrainingVoiceResultUseCase _submitTrainingVoiceResultUseCase;
  final GetTrainingVoiceVideoConfigUseCase _getTrainingVoiceVideoConfigUseCase;
  
  // 领域服务
  final TrainingVoiceService _trainingVoiceService;

  // 状态数据
  List<TrainingVoiceHistoryItem> _history = [];
  TrainingVoiceResult? _currentResult;
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;
  
  // 🎯 新增：临时训练结果数据
  List<Map<String, dynamic>> _tmpResult = [];

  // 视频配置状态
  String? _portraitVideoUrl;
  String? _landscapeVideoUrl;
  bool _isLoadingVideoConfig = false;
  String? _videoConfigError;

  // 训练配置
  int _totalRounds = 1;
  int _roundDuration = 60;
  // 🎯 移除：_maxCounts 已不再需要，使用 getMaxCountsFromTmpResult() 替代
  
  // 延迟清理相关
  Timer? _cleanupTimer;
  static const Duration _cleanupDelay = Duration(seconds: 30); // 30秒后清理

  // 构造函数
  CheckinTrainingVoiceViewModel({
    required GetTrainingVoiceDataAndVideoConfigUseCase getTrainingVoiceDataAndVideoConfigUseCase,
    required GetTrainingVoiceHistoryUseCase getTrainingVoiceHistoryUseCase,
    required SubmitTrainingVoiceResultUseCase submitTrainingVoiceResultUseCase,
    required GetTrainingVoiceVideoConfigUseCase getTrainingVoiceVideoConfigUseCase,
    required TrainingVoiceService trainingVoiceService,
  }) : _getTrainingVoiceDataAndVideoConfigUseCase = getTrainingVoiceDataAndVideoConfigUseCase,
       _getTrainingVoiceHistoryUseCase = getTrainingVoiceHistoryUseCase,
       _submitTrainingVoiceResultUseCase = submitTrainingVoiceResultUseCase,
       _getTrainingVoiceVideoConfigUseCase = getTrainingVoiceVideoConfigUseCase,
       _trainingVoiceService = trainingVoiceService;

  // Getters
  List<TrainingVoiceHistoryItem> get history => _history;
  TrainingVoiceResult? get currentResult => _currentResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;
  String? get portraitVideoUrl => _portraitVideoUrl;
  String? get landscapeVideoUrl => _landscapeVideoUrl;
  bool get isLoadingVideoConfig => _isLoadingVideoConfig;
  String? get videoConfigError => _videoConfigError;
  int get totalRounds => _totalRounds;
  int get roundDuration => _roundDuration;
  // 🎯 新增：临时结果相关getter
  List<Map<String, dynamic>> get tmpResult => _tmpResult;

  // 训练统计信息
  Map<String, dynamic> get trainingVoiceStats => _trainingVoiceService.calculateTrainingVoiceStats(_history);
  bool get isHistoryComplete => _trainingVoiceService.isTrainingVoiceHistoryComplete(_history);
  int? get currentRank => _trainingVoiceService.getCurrentTrainingVoiceRank(_history);

  /// 加载语音训练数据和视频配置
  Future<void> loadTrainingVoiceDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    if (_isLoading || _isLoadingVideoConfig) return;

    try {
      _setLoadingState(true);
      _clearErrors();

      final result = await _getTrainingVoiceDataAndVideoConfigUseCase.execute(
        trainingId,
        productId: productId,
        limit: limit,
      );

      _history = result['history'] as List<TrainingVoiceHistoryItem>;
      _portraitVideoUrl = result['videoConfig']['portraitUrl'] as String?;
      _landscapeVideoUrl = result['videoConfig']['landscapeUrl'] as String?;

      // 🎯 确保历史数据中有当前训练记录
      _ensureCurrentTrainingVoiceRecordExists(trainingId);

      _clearErrors();
    } catch (e) {
      _setError(e.toString());
      _setVideoConfigError(e.toString());
    } finally {
      _setLoadingState(false);
      notifyListeners();
    }
  }

  /// 🎯 新增：确保历史数据中有当前训练记录
  void _ensureCurrentTrainingVoiceRecordExists(String trainingId) {
    // 检查是否已经有当前训练记录
    final hasCurrentRecord = _history.any((item) => item.note == "current");
    
    if (!hasCurrentRecord && _currentResult != null) {
      // 如果没有当前记录但有当前结果，创建一个临时的当前记录
      final currentItem = TrainingVoiceHistoryItem(
        id: _currentResult!.id,
        rank: null, // 排名还未确定
        counts: _currentResult!.counts, // 直接使用当前结果中的counts字段
        countsPerMin: _currentResult!.countsPerMin, // 直接使用当前结果中的countsPerMin
        timestamp: _currentResult!.timestamp,
        note: "current",
      );
      
      // 添加到历史列表的开头
      _history.insert(0, currentItem);
      print('✅ Created temporary current voice training record for ranking update');
    }
  }

  /// 提交语音训练结果
  Future<CheckinTrainingVoiceSubmitResponseApiModel?> submitTrainingVoiceResult(TrainingVoiceResult result) async {
    if (_isSubmitting) return null;

    try {
      _setSubmittingState(true);
      _clearErrors();

      if (!_trainingVoiceService.isValidTrainingVoiceResult(result)) {
        throw Exception('Invalid voice training result data');
      }

      // 🎯 保存当前训练结果，用于后续创建历史记录
      _currentResult = result;

      final response = await _submitTrainingVoiceResultUseCase.execute(result);
      
      // 🎯 关键修改：使用返回的response数据直接更新本地历史数据，而不是重新请求后端
      if (response != null) {
        _updateLocalHistoryWithRanking(response);
      }

      _clearErrors();
      return response; // 返回提交结果
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setSubmittingState(false);
      notifyListeners();
    }
  }

  /// 🎯 新增：使用提交结果直接更新本地历史数据的排名信息
  void _updateLocalHistoryWithRanking(CheckinTrainingVoiceSubmitResponseApiModel response) {
    // 找到当前训练记录（note为"current"的记录）
    final currentIndex = _history.indexWhere((item) => item.note == "current");
    
    if (currentIndex >= 0) {
      // 创建新的历史项，更新排名信息
      final currentItem = _history[currentIndex];
      final updatedItem = TrainingVoiceHistoryItem(
        id: response.id, // 使用API返回的真实ID替换临时ID
        rank: response.rank, // 使用API返回的排名
        counts: currentItem.counts,
        countsPerMin: currentItem.countsPerMin,
        timestamp: currentItem.timestamp,
        note: currentItem.note,
      );
      
      // 更新历史列表
      _history[currentIndex] = updatedItem;
      
      print('✅ Updated local voice training history with ranking: rank=${response.rank}, id=${response.id}');
    } else {
      // 🎯 如果没有找到当前训练记录，创建一个新的
      print('⚠️ Current voice training item not found, creating new one with ranking');
      _createCurrentTrainingVoiceHistoryItem(response);
    }
  }

  /// 🎯 新增：创建当前训练的历史项
  void _createCurrentTrainingVoiceHistoryItem(CheckinTrainingVoiceSubmitResponseApiModel response) {
    // 从当前结果中获取counts，直接使用counts字段
    final counts = _currentResult?.counts ?? 0;
    final timestamp = _currentResult?.timestamp ?? DateTime.now().millisecondsSinceEpoch;
    
    final newItem = TrainingVoiceHistoryItem(
      id: response.id,
      rank: response.rank,
      counts: counts,
      countsPerMin: _currentResult?.countsPerMin ?? 0.0,
      timestamp: timestamp,
      note: "current",
    );
    
    // 添加到历史列表的开头（最新的记录）
    _history.insert(0, newItem);
    
    print('✅ Created new current voice training history item: rank=${response.rank}, id=${response.id}, counts=$counts');
  }

  /// 🎯 新增：创建临时的当前训练记录（不提交到后端）
  void createTemporaryCurrentTrainingVoiceRecord({
    required String trainingId,
    String? productId,
    required double countsPerMin,
    required int maxCounts,
  }) {
    // 创建临时的当前训练记录
    final temporaryItem = TrainingVoiceHistoryItem(
      id: null, // 临时ID设为null
      rank: null, // 排名还未确定
      counts: maxCounts, // 直接使用传入的maxCounts
      countsPerMin: countsPerMin,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      note: "current", // 标记为当前训练
    );
    
    // 🎯 插入到历史数据的第一位
    _history.insert(0, temporaryItem);
    
    print('✅ Created temporary current voice training record: countsPerMin=' + countsPerMin.toStringAsFixed(2) + ', rank=null, id=null, note=current');
    
    // 通知UI更新
    notifyListeners();
  }

  /// 🎯 新增：添加round结果到临时结果列表
  void addRoundToTmpResult(int roundNumber, int counts) {
    final now = DateTime.now();
    
    final roundResult = {
      "roundNumber": roundNumber,
      "counts": counts,
      "timestamp": now.millisecondsSinceEpoch,
      "roundDuration": _roundDuration,
    };
    
    _tmpResult.add(roundResult);
    print('Added voice training round $roundNumber result: $counts counts to tmpResult');
    
    // 通知UI更新
    notifyListeners();
  }

  /// 🎯 新增：清理临时结果数据
  void clearTmpResult() {
    _tmpResult.clear();
    print('Cleared voice training tmpResult after final submission');
    
    // 通知UI更新
    notifyListeners();
  }

  /// 🎯 新增：获取临时结果中的最大counts
  int getMaxCountsFromTmpResult() {
    if (_tmpResult.isEmpty) return 0;
    
    int maxCounts = 0;
    for (var round in _tmpResult) {
      if (round["counts"] > maxCounts) {
        maxCounts = round["counts"];
      }
    }
    return maxCounts;
  }

  /// 更新语音训练配置
  void updateTrainingVoiceConfig({
    int? totalRounds,
    int? roundDuration,
  }) {
    if (totalRounds != null) _totalRounds = totalRounds;
    if (roundDuration != null) _roundDuration = roundDuration;
    notifyListeners();
  }

  /// 刷新语音训练历史数据
  Future<void> refreshTrainingVoiceHistory(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    await loadTrainingVoiceDataAndVideoConfig(trainingId, productId: productId, limit: limit);
  }

  /// 清除错误状态
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _history.clear();
    _currentResult = null;
    _error = null;
    _videoConfigError = null;
    _isLoading = false;
    _isSubmitting = false;
    _isLoadingVideoConfig = false;
    
    // 🎯 新增：清理临时结果数据
    _tmpResult.clear();
    
    // 🎯 清理视频配置
    _portraitVideoUrl = null;
    _landscapeVideoUrl = null;
    
    notifyListeners();
  }

  /// 智能延迟清理：延迟清理数据以提升用户体验
  void scheduleCleanup() {
    // 取消之前的清理定时器
    _cleanupTimer?.cancel();
    
    // 设置新的延迟清理定时器
    _cleanupTimer = Timer(_cleanupDelay, () {
      _cleanupData();
    });
  }

  /// 立即清理数据
  void _cleanupData() {
    _history.clear();
    _currentResult = null;
    _error = null;
    _videoConfigError = null;
    _isLoading = false;
    _isSubmitting = false;
    _isLoadingVideoConfig = false;
    
    // 清理临时结果数据
    _tmpResult.clear();
    
    // 清理视频配置
    _portraitVideoUrl = null;
    _landscapeVideoUrl = null;
    
    notifyListeners();
  }

  /// 取消延迟清理（当用户重新访问页面时）
  void cancelCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// 检查是否有缓存数据
  bool get hasCachedData => _history.isNotEmpty || _currentResult != null;

  @override
  void dispose() {
    // 取消定时器
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    // 立即清理数据
    _cleanupData();
    
    super.dispose();
  }

  // 私有方法
  void _setLoadingState(bool loading) {
    _isLoading = loading;
  }

  void _setSubmittingState(bool submitting) {
    _isSubmitting = submitting;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearErrors() {
    _error = null;
    _videoConfigError = null;
  }

  void _setVideoConfigError(String error) {
    _videoConfigError = error;
  }
}
