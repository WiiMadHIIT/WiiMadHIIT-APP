import 'package:flutter/material.dart';
import '../../domain/usecases/get_challenge_game_data_and_video_config_usecase.dart';
import '../../domain/services/challenge_game_service.dart';
import '../../domain/entities/challenge_game/challenge_game_history_item.dart';
import '../../domain/entities/challenge_game/challenge_game_result.dart';
import '../../data/models/challenge_game_api_model.dart';

/// 挑战游戏页面 ViewModel
class ChallengeGameViewModel extends ChangeNotifier {
  // 用例依赖
  final GetChallengeGameDataAndVideoConfigUseCase _getChallengeGameDataAndVideoConfigUseCase;
  final SubmitChallengeGameResultUseCase _submitChallengeGameResultUseCase;
  
  // 领域服务
  final ChallengeGameService _challengeGameService;

  // 状态数据
  List<ChallengeGameHistoryItem> _history = [];
  ChallengeGameResult? _currentResult;
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;
  
  // 🎯 新增：临时挑战游戏结果数据
  List<Map<String, dynamic>> _tmpResult = [];

  // 视频配置状态
  String? _portraitVideoUrl;
  String? _landscapeVideoUrl;
  bool _isLoadingVideoConfig = false;
  String? _videoConfigError;

  // 挑战游戏配置
  int _totalRounds = 1;
  int _roundDuration = 60;
  int _allowedTimes = 0; // 🎯 新增：剩余挑战次数
  // 🎯 移除：_maxCounts 已不再需要，使用 getMaxCountsFromTmpResult() 替代

  // 构造函数
  ChallengeGameViewModel({
    required GetChallengeGameDataAndVideoConfigUseCase getChallengeGameDataAndVideoConfigUseCase,
    required SubmitChallengeGameResultUseCase submitChallengeGameResultUseCase,
    required ChallengeGameService challengeGameService,
  }) : _getChallengeGameDataAndVideoConfigUseCase = getChallengeGameDataAndVideoConfigUseCase,
       _submitChallengeGameResultUseCase = submitChallengeGameResultUseCase,
       _challengeGameService = challengeGameService;

  // Getters
  List<ChallengeGameHistoryItem> get history => _history;
  ChallengeGameResult? get currentResult => _currentResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;
  String? get portraitVideoUrl => _portraitVideoUrl;
  String? get landscapeVideoUrl => _landscapeVideoUrl;
  bool get isLoadingVideoConfig => _isLoadingVideoConfig;
  String? get videoConfigError => _videoConfigError;
  int get totalRounds => _totalRounds;
  int get roundDuration => _roundDuration;
  int get allowedTimes => _allowedTimes; // 🎯 新增：剩余挑战次数
  // 🎯 新增：临时结果相关getter
  List<Map<String, dynamic>> get tmpResult => _tmpResult;

  // 挑战游戏统计信息
  Map<String, dynamic> get challengeGameStats => _challengeGameService.calculateChallengeGameStats(_history);
  bool get isHistoryComplete => _challengeGameService.isChallengeGameHistoryComplete(_history);
  int? get currentRank => _challengeGameService.getCurrentChallengeGameRank(_history);

  /// 加载挑战游戏数据和视频配置
  Future<void> loadChallengeGameDataAndVideoConfig(
    String challengeId, // 🎯 修改：使用challengeId
    {
    int? limit,
  }) async {
    if (_isLoading || _isLoadingVideoConfig) return;

    try {
      _setLoadingState(true);
      _clearErrors();

      final result = await _getChallengeGameDataAndVideoConfigUseCase.execute(
        challengeId, // 🎯 修改：使用challengeId
        limit: limit,
      );

      _history = result['history'] as List<ChallengeGameHistoryItem>;
      _portraitVideoUrl = result['videoConfig']['portraitUrl'] as String?;
      _landscapeVideoUrl = result['videoConfig']['landscapeUrl'] as String?;

      // 🎯 确保历史数据中有当前挑战游戏记录
      _ensureCurrentChallengeGameRecordExists(challengeId);

      _clearErrors();
    } catch (e) {
      _setError(e.toString());
      _setVideoConfigError(e.toString());
    } finally {
      _setLoadingState(false);
      notifyListeners();
    }
  }

  /// 🎯 新增：确保历史数据中有当前挑战游戏记录
  void _ensureCurrentChallengeGameRecordExists(String challengeId) {
    // 检查是否已经有当前挑战游戏记录
    final hasCurrentRecord = _history.any((item) => item.note == "current");
    
    if (!hasCurrentRecord && _currentResult != null) {
      // 如果没有当前记录但有当前结果，创建一个临时的当前记录
      final currentItem = ChallengeGameHistoryItem(
        id: _currentResult!.id,
        rank: null, // 排名还未确定
        counts: _currentResult!.maxCounts,
        timestamp: _currentResult!.timestamp,
        note: "current",
        name: "Current User", // 🎯 新增：用户名
        userId: "current_user", // 🎯 新增：用户ID
      );
      
      // 添加到历史列表的开头
      _history.insert(0, currentItem);
      print('✅ Created temporary current challenge game record for ranking update');
    }
  }

  /// 提交挑战游戏结果
  Future<ChallengeGameSubmitResponseApiModel?> submitChallengeGameResult(ChallengeGameResult result) async {
    if (_isSubmitting) return null;

    try {
      _setSubmittingState(true);
      _clearErrors();

      if (!_challengeGameService.isValidChallengeGameResult(result)) {
        throw Exception('Invalid challenge game result data');
      }

      // 🎯 保存当前挑战游戏结果，用于后续创建历史记录
      _currentResult = result;

      final response = await _submitChallengeGameResultUseCase.execute(result);
      
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
  void _updateLocalHistoryWithRanking(ChallengeGameSubmitResponseApiModel response) {
    // 🎯 更新剩余挑战次数
    _allowedTimes = response.allowedTimes;
    
    // 找到当前挑战游戏记录（note为"current"的记录）
    final currentIndex = _history.indexWhere((item) => item.note == "current");
    
    if (currentIndex >= 0) {
      // 创建新的历史项，更新排名信息
      final currentItem = _history[currentIndex];
      final updatedItem = ChallengeGameHistoryItem(
        id: response.id, // 使用API返回的真实ID替换临时ID
        rank: response.rank, // 使用API返回的排名
        counts: currentItem.counts,
        timestamp: currentItem.timestamp,
        note: currentItem.note,
        name: currentItem.name, // 🎯 新增：用户名
        userId: currentItem.userId, // 🎯 新增：用户ID
      );
      
      // 更新历史列表
      _history[currentIndex] = updatedItem;
      
      print('✅ Updated local history with ranking: rank=${response.rank}, id=${response.id}, allowedTimes=${response.allowedTimes}');
    } else {
      // 🎯 如果没有找到当前挑战游戏记录，创建一个新的
      print('⚠️ Current challenge game item not found, creating new one with ranking');
      _createCurrentChallengeGameHistoryItem(response);
    }
  }

  /// 🎯 新增：创建当前挑战游戏的历史项
  void _createCurrentChallengeGameHistoryItem(ChallengeGameSubmitResponseApiModel response) {
    // 从当前结果中获取counts，如果没有则使用默认值
    final counts = _currentResult?.maxCounts ?? 0;
    final timestamp = _currentResult?.timestamp ?? DateTime.now().millisecondsSinceEpoch;
    
    final newItem = ChallengeGameHistoryItem(
      id: response.id,
      rank: response.rank,
      counts: counts,
      timestamp: timestamp,
      note: "current",
      name: "Current User", // 🎯 新增：用户名
      userId: "current_user", // 🎯 新增：用户ID
    );
    
    // 添加到历史列表的开头（最新的记录）
    _history.insert(0, newItem);
    
    print('✅ Created new current challenge game history item: rank=${response.rank}, id=${response.id}, counts=$counts');
  }

  /// 🎯 新增：创建临时的当前挑战游戏记录（不提交到后端）
  void createTemporaryCurrentChallengeGameRecord({
    required String challengeId, // 🎯 修改：使用challengeId
    required int maxCounts,
  }) {
    // 创建临时的当前挑战游戏记录
    final temporaryItem = ChallengeGameHistoryItem(
      id: null, // 临时ID设为null
      rank: null, // 排名还未确定
      counts: maxCounts,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      note: "current", // 标记为当前挑战游戏
      name: "Current User", // 🎯 新增：用户名
      userId: "current_user", // 🎯 新增：用户ID
    );
    
    // 🎯 插入到历史数据的第一位
    _history.insert(0, temporaryItem);
    
    print('✅ Created temporary current challenge game record: counts=$maxCounts, rank=null, id=null, note=current');
    
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
    print('Added round $roundNumber result: $counts counts to tmpResult');
    
    // 通知UI更新
    notifyListeners();
  }

  /// 🎯 新增：清理临时结果数据
  void clearTmpResult() {
    _tmpResult.clear();
    print('Cleared tmpResult after final submission');
    
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

  /// 更新挑战游戏配置
  void updateChallengeGameConfig({
    int? totalRounds,
    int? roundDuration,
    int? allowedTimes,
  }) {
    if (totalRounds != null) _totalRounds = totalRounds;
    if (roundDuration != null) _roundDuration = roundDuration;
    if (allowedTimes != null) _allowedTimes = allowedTimes;
    notifyListeners();
  }

  /// 刷新历史数据
  Future<void> refreshHistory(
    String challengeId, // 🎯 修改：使用challengeId
    {
    int? limit,
  }) async {
    await loadChallengeGameDataAndVideoConfig(challengeId, limit: limit);
  }

  /// 清除错误状态
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    // 🎯 清理所有数据集合
    _history.clear();
    _tmpResult.clear();
    
    // 🎯 清理对象引用
    _currentResult = null;
    
    // 🎯 清理错误状态
    _error = null;
    _videoConfigError = null;
    
    // 🎯 重置所有状态标志
    _isLoading = false;
    _isSubmitting = false;
    _isLoadingVideoConfig = false;
    
    // 🎯 重置配置数据
    _totalRounds = 1;
    _roundDuration = 60;
    _allowedTimes = 0;
    
    // 🎯 清理视频配置
    _portraitVideoUrl = null;
    _landscapeVideoUrl = null;
    
    print('🎯 ViewModel reset completed - all data cleared');
    notifyListeners();
  }
  
  /// 🎯 苹果级优化：智能清理策略 - 保留核心数据，清理占用内存大的数据
  void smartCleanup() {
    // 🎯 保留核心数据（避免重新请求API）
    // _history 保留 - 核心业务数据，用户历史记录
    // _totalRounds, _roundDuration, _allowedTimes 保留 - 核心配置数据
    
    // 🎯 清理占用内存大的数据
    _tmpResult.clear();        // 临时结果数据可以清理
    _currentResult = null;     // 当前结果对象可以清理
    _portraitVideoUrl = null;  // 视频URL可以清理（重新加载很快）
    _landscapeVideoUrl = null; // 视频URL可以清理（重新加载很快）
    
    // 🎯 重置状态标志
    _isLoading = false;
    _isSubmitting = false;
    _isLoadingVideoConfig = false;
    _error = null;
    _videoConfigError = null;
    
    print('🎯 ChallengeGameViewModel smart cleanup completed - core data preserved');
    notifyListeners();
  }
  
  /// 🎯 苹果级优化：检查是否需要重新加载数据
  bool get needsReload {
    // 如果没有历史数据，需要重新加载
    if (_history.isEmpty) return true;
    
    // 如果没有核心配置数据，需要重新加载
    if (_totalRounds <= 0 || _roundDuration <= 0) return true;
    
    // 如果有错误，需要重新加载
    if (_error != null) return true;
    
    // 如果视频配置丢失，需要重新加载
    if (_portraitVideoUrl == null && _landscapeVideoUrl == null) return true;
    
    return false;
  }
  
  /// 🎯 苹果级优化：检查是否需要重新加载视频配置
  bool get needsVideoConfigReload {
    // 如果视频配置丢失，需要重新加载
    if (_portraitVideoUrl == null && _landscapeVideoUrl == null) return true;
    
    // 如果视频配置有错误，需要重新加载
    if (_videoConfigError != null) return true;
    
    return false;
  }
  
  /// 🎯 苹果级优化：智能加载策略 - 只加载必要的数据
  Future<void> smartLoadChallengeGameData(
    String challengeId, {
    int? limit,
    bool forceReload = false,
  }) async {
    // 🎯 如果强制重新加载，直接调用完整加载
    if (forceReload) {
      await loadChallengeGameDataAndVideoConfig(challengeId, limit: limit);
      return;
    }
    
    // 🎯 智能判断：如果核心数据完整，只加载视频配置
    if (!needsReload && needsVideoConfigReload) {
      print('🎯 Core data intact, only reloading video config');
      await _loadOnlyVideoConfig(challengeId);
      return;
    }
    
    // 🎯 如果核心数据缺失，执行完整加载
    if (needsReload) {
      print('🎯 Core data missing, performing full load');
      await loadChallengeGameDataAndVideoConfig(challengeId, limit: limit);
      return;
    }
    
    // 🎯 数据完整，无需加载
    print('🎯 All data intact, no reload needed');
  }
  
  /// 🎯 苹果级优化：只加载视频配置（轻量级操作）
  Future<void> _loadOnlyVideoConfig(String challengeId) async {
    if (_isLoadingVideoConfig) return;
    
    try {
      _setLoadingState(true);
      _clearErrors();
      
      // 🎯 只获取视频配置，不获取历史数据
      final videoConfigResult = await _getChallengeGameDataAndVideoConfigUseCase.execute(
        challengeId,
        limit: 0, // 不获取历史数据
      );
      
      // 🎯 只更新视频配置
      _portraitVideoUrl = videoConfigResult['videoConfig']['portraitUrl'] as String?;
      _landscapeVideoUrl = videoConfigResult['videoConfig']['landscapeUrl'] as String?;
      
      _clearErrors();
      print('🎯 Video config reloaded successfully');
    } catch (e) {
      _setVideoConfigError(e.toString());
      print('❌ Error reloading video config: $e');
    } finally {
      _setLoadingState(false);
      notifyListeners();
    }
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
  
  /// 🎯 新增：彻底清理所有资源
  @override
  void dispose() {
    // 🎯 先重置所有数据
    reset();
    
    // 🎯 清理所有集合引用
    _history = [];
    _tmpResult = [];
    
    // 🎯 强制垃圾回收提示（可选）
    print('🎯 ViewModel disposed - all resources cleaned up');
    
    super.dispose();
  }
} 