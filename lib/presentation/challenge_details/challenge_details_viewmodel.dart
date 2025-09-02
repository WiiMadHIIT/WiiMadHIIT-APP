import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/usecases/get_challenge_details_usecase.dart';
import '../../domain/entities/challenge_details/challenge_details.dart';
import '../../domain/services/challenge_details_service.dart';

class ChallengeDetailsViewModel extends ChangeNotifier {
  final GetChallengeBasicUseCase getChallengeBasicUseCase;
  final GetChallengePlayoffsUseCase getChallengePlayoffsUseCase;
  final GetChallengePreseasonUseCase getChallengePreseasonUseCase;
  final ChallengeDetailsService challengeDetailsService;

  // 独立API数据支持
  ChallengeBasic? challengeBasic;
  bool isBasicLoading = false;
  String? basicError;

  PlayoffData? playoffData;
  bool isPlayoffsLoading = false;
  String? playoffsError;

  PreseasonData? preseasonData;
  bool isPreseasonLoading = false;
  String? preseasonError;
  
  // 延迟清理相关
  Timer? _cleanupTimer;
  static const Duration _cleanupDelay = Duration(seconds: 30); // 30秒后清理

  ChallengeDetailsViewModel({
    required this.getChallengeBasicUseCase,
    required this.getChallengePlayoffsUseCase,
    required this.getChallengePreseasonUseCase,
    required this.challengeDetailsService,
  });

  /// 加载挑战基础信息
  Future<void> loadChallengeBasic(String challengeId) async {
    try {
      isBasicLoading = true;
      basicError = null;
      notifyListeners();

      challengeBasic = await getChallengeBasicUseCase.execute(challengeId);
    } catch (e) {
      basicError = e.toString();
      challengeBasic = null;
    } finally {
      isBasicLoading = false;
      notifyListeners();
    }
  }

  /// 加载季后赛数据
  Future<void> loadChallengePlayoffs(String challengeId) async {
    try {
      isPlayoffsLoading = true;
      playoffsError = null;
      notifyListeners();

      playoffData = await getChallengePlayoffsUseCase.execute(challengeId);
    } catch (e) {
      playoffsError = e.toString();
      playoffData = null;
    } finally {
      isPlayoffsLoading = false;
      notifyListeners();
    }
  }

  /// 加载季前赛数据
  Future<void> loadChallengePreseason(String challengeId, {int page = 1}) async {
    try {
      isPreseasonLoading = true;
      preseasonError = null;
      notifyListeners();

      if (page == 1) {
        // 第一页：替换数据
        preseasonData = await getChallengePreseasonUseCase.execute(challengeId, page: page);
      } else {
        // 后续页：追加数据
        final newData = await getChallengePreseasonUseCase.execute(challengeId, page: page);
        if (preseasonData != null && newData != null) {
          // 合并记录
          final combinedRecords = [...preseasonData!.records, ...newData.records];
          // 更新分页信息
          preseasonData = PreseasonData(
            records: combinedRecords,
            pagination: newData.pagination,
          );
        } else {
          preseasonData = newData;
        }
      }
    } catch (e) {
      preseasonError = e.toString();
      if (page == 1) {
        preseasonData = null;
      }
    } finally {
      isPreseasonLoading = false;
      notifyListeners();
    }
  }

  /// 加载季前赛下一页数据
  Future<void> loadChallengePreseasonNextPage(String challengeId) async {
    if (preseasonData != null && 
        preseasonData!.pagination.currentPage < preseasonData!.pagination.totalPages) {
      await loadChallengePreseason(
        challengeId, 
        page: preseasonData!.pagination.currentPage + 1,
      );
    }
  }

  /// 并行加载所有数据（保留用于向后兼容）
  @Deprecated('Use individual load methods for better performance')
  Future<void> loadAllData(String challengeId) async {
    await Future.wait([
      loadChallengeBasic(challengeId),
      loadChallengePlayoffs(challengeId),
      loadChallengePreseason(challengeId),
    ]);
  }

  /// 检查是否有任何数据加载失败（保留用于向后兼容）
  @Deprecated('Use individual error checks for better performance')
  bool get hasAnyError => basicError != null || playoffsError != null || preseasonError != null;

  /// 检查是否所有数据都在加载中（保留用于向后兼容）
  @Deprecated('Use individual loading checks for better performance')
  bool get isAllLoading => isBasicLoading && isPlayoffsLoading && isPreseasonLoading;

  /// 检查挑战是否已完成
  bool get isChallengeCompleted {
    if (playoffData == null) return false;
    return challengeDetailsService.isChallengeCompletedWithPlayoffs(playoffData!);
  }

  /// 获取当前活跃的季后赛阶段
  String? get currentPlayoffStage {
    if (playoffData == null) return null;
    return challengeDetailsService.getCurrentPlayoffStageWithPlayoffs(playoffData!);
  }

  /// 检查用户是否参与挑战
  bool isUserParticipating(String userId) {
    if (playoffData == null) return false;
    return challengeDetailsService.isUserParticipatingWithPlayoffs(playoffData!, userId);
  }

  /// 获取用户的挑战统计信息
  Map<String, dynamic> getUserChallengeStats(String userId) {
    if (playoffData == null) {
      return {
        'totalMatches': 0,
        'wins': 0,
        'losses': 0,
        'winRate': 0.0,
      };
    }
    return challengeDetailsService.getUserChallengeStatsWithPlayoffs(playoffData!, userId);
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
    // 清理独立数据
    challengeBasic = null;
    playoffData = null;
    preseasonData = null;
    basicError = null;
    playoffsError = null;
    preseasonError = null;
    
    notifyListeners();
  }

  /// 取消延迟清理（当用户重新访问页面时）
  void cancelCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// 检查是否有缓存数据
  bool get hasCachedData => challengeBasic != null;

  @override
  void dispose() {
    // 取消定时器
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    // 立即清理数据
    _cleanupData();
    
    super.dispose();
  }

  // getter方法（使用独立实体）
  /// 获取挑战名称
  String get challengeName => challengeBasic?.challengeName ?? '';

  /// 获取背景图片
  String get backgroundImage => challengeBasic?.backgroundImage ?? '';

  /// 获取视频URL
  String get videoUrl => challengeBasic?.videoUrl ?? '';

  /// 获取规则数据
  ChallengeRules? get rules => challengeBasic?.rules;

  /// 获取季后赛数据
  PlayoffData? get playoffs => playoffData;

  /// 获取季前赛数据
  PreseasonData? get preseason => preseasonData;

  /// 获取游戏追踪数据
  GameTrackerData? get gameTracker => challengeBasic?.gameTracker;
} 