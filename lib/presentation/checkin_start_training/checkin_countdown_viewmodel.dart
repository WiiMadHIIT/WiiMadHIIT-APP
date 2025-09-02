import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/usecases/get_training_countdown_data_and_video_config_usecase.dart';
import '../../domain/services/training_countdown_service.dart';
import '../../domain/entities/checkin_countdown/training_countdown_history_item.dart';
import '../../domain/entities/checkin_countdown/training_countdown_result.dart';
import '../../data/models/training_countdown_api_model.dart';

/// 倒计时训练页面 ViewModel
class CheckinCountdownViewModel extends ChangeNotifier {
  // 用例依赖
  final GetTrainingCountdownDataAndVideoConfigUseCase _getTrainingCountdownDataAndVideoConfigUseCase;
  final GetTrainingCountdownHistoryUseCase _getTrainingCountdownHistoryUseCase;
  final SubmitTrainingCountdownResultUseCase _submitTrainingCountdownResultUseCase;
  final GetTrainingCountdownVideoConfigUseCase _getTrainingCountdownVideoConfigUseCase;
  
  // 领域服务
  final TrainingCountdownService _trainingCountdownService;

  // 状态数据
  List<TrainingCountdownHistoryItem> _history = [];
  TrainingCountdownResult? _currentResult;
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;
  


  // 视频配置状态
  String? _portraitVideoUrl;
  String? _landscapeVideoUrl;
  bool _isLoadingVideoConfig = false;
  String? _videoConfigError;

  // 训练配置
  int _totalRounds = 1;
  int _roundDuration = 60;
  int _preCountdown = 10;
  
  // 🎯 倒计时训练特有状态
  int _countdown = 0;
  bool _isCounting = false;
  bool _showPreCountdown = false;
  
  // 延迟清理相关
  Timer? _cleanupTimer;
  static const Duration _cleanupDelay = Duration(seconds: 30); // 30秒后清理

  // 构造函数
  CheckinCountdownViewModel({
    required GetTrainingCountdownDataAndVideoConfigUseCase getTrainingCountdownDataAndVideoConfigUseCase,
    required GetTrainingCountdownHistoryUseCase getTrainingCountdownHistoryUseCase,
    required SubmitTrainingCountdownResultUseCase submitTrainingCountdownResultUseCase,
    required GetTrainingCountdownVideoConfigUseCase getTrainingCountdownVideoConfigUseCase,
    required TrainingCountdownService trainingCountdownService,
  }) : _getTrainingCountdownDataAndVideoConfigUseCase = getTrainingCountdownDataAndVideoConfigUseCase,
       _getTrainingCountdownHistoryUseCase = getTrainingCountdownHistoryUseCase,
       _submitTrainingCountdownResultUseCase = submitTrainingCountdownResultUseCase,
       _getTrainingCountdownVideoConfigUseCase = getTrainingCountdownVideoConfigUseCase,
       _trainingCountdownService = trainingCountdownService;

  // Getters
  List<TrainingCountdownHistoryItem> get history => _history;
  TrainingCountdownResult? get currentResult => _currentResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;
  String? get portraitVideoUrl => _portraitVideoUrl;
  String? get landscapeVideoUrl => _landscapeVideoUrl;
  bool get isLoadingVideoConfig => _isLoadingVideoConfig;
  String? get videoConfigError => _videoConfigError;
  int get totalRounds => _totalRounds;
  int get roundDuration => _roundDuration;
  int get preCountdown => _preCountdown;
  
  // 🎯 倒计时训练特有getter
  int get countdown => _countdown;
  bool get isCounting => _isCounting;
  bool get showPreCountdown => _showPreCountdown;
  


  // 训练统计信息
  Map<String, dynamic> get trainingCountdownStats => _trainingCountdownService.calculateTrainingCountdownStats(_history);
  bool get isHistoryComplete => _trainingCountdownService.isTrainingCountdownHistoryComplete(_history);
  int? get currentRank => _trainingCountdownService.getCurrentTrainingCountdownRank(_history);

  /// 加载倒计时训练数据和视频配置
  Future<void> loadTrainingCountdownDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    if (_isLoading || _isLoadingVideoConfig) return;

    try {
      _setLoadingState(true);
      _clearErrors();

      final result = await _getTrainingCountdownDataAndVideoConfigUseCase.execute(
        trainingId,
        productId: productId,
        limit: limit,
      );

      _history = result['history'] as List<TrainingCountdownHistoryItem>;
      _portraitVideoUrl = result['videoConfig']['portraitUrl'] as String?;
      _landscapeVideoUrl = result['videoConfig']['landscapeUrl'] as String?;

      // 🎯 确保历史数据中有当前训练记录
      _ensureCurrentTrainingCountdownRecordExists(trainingId);

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
  void _ensureCurrentTrainingCountdownRecordExists(String trainingId) {
    // 检查是否已经有当前训练记录
    final hasCurrentRecord = _history.any((item) => item.note == "current");
    
    if (!hasCurrentRecord && _currentResult != null) {
      // 如果没有当前记录但有当前结果，创建一个临时的当前记录
      final currentItem = TrainingCountdownHistoryItem(
        id: _currentResult!.id,
        rank: null, // 排名还未确定
        daySeconds: _currentResult!.seconds,
        seconds: _currentResult!.seconds,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: "current",
      );
      
      // 添加到历史列表的开头
      _history.insert(0, currentItem);
      print('✅ Created temporary current countdown training record for ranking update');
    }
  }

  /// 提交倒计时训练结果
  Future<TrainingCountdownSubmitResponseApiModel?> submitTrainingCountdownResult(TrainingCountdownResult result) async {
    if (_isSubmitting) return null;

    try {
      _setSubmittingState(true);
      _clearErrors();

      if (!_trainingCountdownService.isValidTrainingCountdownResult(result)) {
        throw Exception('Invalid countdown training result data');
      }

      // 🎯 保存当前训练结果，用于后续创建历史记录
      _currentResult = result;

      final response = await _submitTrainingCountdownResultUseCase.execute(result);
      
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
  void _updateLocalHistoryWithRanking(TrainingCountdownSubmitResponseApiModel response) {
    // 找到当前训练记录（note为"current"的记录）
    final currentIndex = _history.indexWhere((item) => item.note == "current");
    
    if (currentIndex >= 0) {
      // 创建新的历史项，更新排名信息
      final currentItem = _history[currentIndex];
      final updatedItem = TrainingCountdownHistoryItem(
        id: response.id, // 使用API返回的真实ID替换临时ID
        rank: response.rank, // 使用API返回的排名
        daySeconds: response.daySeconds,
        seconds: currentItem.seconds,
        timestamp: currentItem.timestamp,
        note: currentItem.note,
      );
      
      // 更新历史列表
      _history[currentIndex] = updatedItem;
      
      print('✅ Updated local countdown training history with ranking: rank=${response.rank}, id=${response.id}');
    } else {
      // 🎯 如果没有找到当前训练记录，创建一个新的
      print('⚠️ Current countdown training item not found, creating new one with ranking');
      _createCurrentTrainingCountdownHistoryItem(response);
    }
  }

  /// 🎯 新增：创建当前训练的历史项
  void _createCurrentTrainingCountdownHistoryItem(TrainingCountdownSubmitResponseApiModel response) {
    // 从当前结果中获取seconds，如果没有则使用默认值
    final seconds = _currentResult?.seconds ?? 0;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final newItem = TrainingCountdownHistoryItem(
      id: response.id,
      rank: response.rank,
      daySeconds: response.daySeconds,        // ✅ 修复：使用API返回的 daySeconds
      seconds: seconds,
      timestamp: timestamp,
      note: "current",
    );
    
    // 添加到历史列表的开头（最新的记录）
    _history.insert(0, newItem);
    
    print('✅ Created new current countdown training history item: rank=${response.rank}, id=${response.id}, daySeconds=${response.daySeconds}, seconds=$seconds');
  }

  /// 🎯 新增：创建临时的当前训练记录（不提交到后端）
  void createTemporaryCurrentTrainingCountdownRecord({
    required String trainingId,
    String? productId,
    required int seconds,
  }) {
    // 🎯 先将原来历史数据中所有note为"current"的记录改为null
    for (int i = 0; i < _history.length; i++) {
      if (_history[i].note == "current") {
        _history[i] = _history[i].copyWith(note: null);
      }
    }
    
    // 创建临时的当前训练记录
    final temporaryItem = TrainingCountdownHistoryItem(
      id: null, // 临时ID设为null
      rank: null, // 排名还未确定
      daySeconds: null,
      seconds: seconds,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      note: "current", // 标记为当前训练
    );
    
    // 🎯 插入到历史数据的第一位
    _history.insert(0, temporaryItem);
    
    print('✅ Created temporary current countdown training record: seconds=$seconds, rank=null, id=null, note=current');
    
    // 通知UI更新
    notifyListeners();
  }



  /// 更新倒计时训练配置
  void updateTrainingCountdownConfig({
    int? totalRounds,
    int? roundDuration,
    int? preCountdown,
  }) {
    if (totalRounds != null) _totalRounds = totalRounds;
    if (roundDuration != null) _roundDuration = roundDuration;
    if (preCountdown != null) _preCountdown = preCountdown;
    notifyListeners();
  }

  /// 🎯 倒计时训练特有方法
  void startCountdown(int duration) {
    _countdown = duration;
    _isCounting = true;
    notifyListeners();
  }

  void stopCountdown() {
    _isCounting = false;
    notifyListeners();
  }

  void updateCountdown(int newCountdown) {
    _countdown = newCountdown;
    notifyListeners();
  }

  void setPreCountdown(int value) {
    _preCountdown = value;
    _showPreCountdown = true;
    notifyListeners();
  }

  void hidePreCountdown() {
    _showPreCountdown = false;
    notifyListeners();
  }

  /// 刷新倒计时训练历史数据
  Future<void> refreshTrainingCountdownHistory(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    await loadTrainingCountdownDataAndVideoConfig(trainingId, productId: productId, limit: limit);
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
    
    // 倒计时训练特有状态重置
    _countdown = 0;
    _isCounting = false;
    _showPreCountdown = false;
    
    // 清理视频配置
    _portraitVideoUrl = null;
    _landscapeVideoUrl = null;
    
    notifyListeners();
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
    
    // 倒计时训练特有状态重置
    _countdown = 0;
    _isCounting = false;
    _showPreCountdown = false;
    
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
}
