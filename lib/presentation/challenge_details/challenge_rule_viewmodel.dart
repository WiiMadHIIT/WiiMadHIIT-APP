import 'package:flutter/foundation.dart';
import '../../domain/entities/challenge_rule/challenge_rule.dart';
import '../../domain/entities/challenge_rule/challenge_config.dart';
import '../../domain/usecases/get_challenge_rule_usecase.dart';

class ChallengeRuleViewModel extends ChangeNotifier {
  final GetChallengeRuleUseCase _useCase;

  // 状态变量
  bool _isLoading = false;
  String? _error;
  String? _challengeId;
  
  // 数据变量
  List<ChallengeRule> _challengeRules = [];
  ChallengeConfig? _challengeConfig;
  Map<String, dynamic>? _ruleStatistics;
  Map<String, dynamic>? _configStatistics;
  int _totalRounds = 3;
  int _roundDuration = 80;

  ChallengeRuleViewModel({
    GetChallengeRuleUseCase? useCase,
  }) : _useCase = useCase ?? GetChallengeRuleUseCase();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get challengeId => _challengeId;
  List<ChallengeRule> get challengeRules => _challengeRules;
  ChallengeConfig? get challengeConfig => _challengeConfig;
  Map<String, dynamic>? get ruleStatistics => _ruleStatistics;
  Map<String, dynamic>? get configStatistics => _configStatistics;
  int get totalRounds => _totalRounds;
  int get roundDuration => _roundDuration;

  // 计算属性
  bool get hasData => _challengeRules.isNotEmpty && _challengeConfig != null;
  bool get hasError => _error != null;
  bool get hasChallengeRules => _challengeRules.isNotEmpty;
  // 远程投影教程移除，但页面仍保留本地弹层，始终可用
  bool get hasProjectionTutorial => true;
  bool get hasValidConfig => _challengeConfig != null && _challengeConfig!.isValid;

  /// 加载挑战规则数据
  Future<void> loadChallengeRule(String challengeId) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _useCase.execute(challengeId);
      
      _challengeId = challengeId;
      _challengeRules = result['challengeRules'] as List<ChallengeRule>;
      _challengeConfig = result['challengeConfig'] as ChallengeConfig;
      _ruleStatistics = result['ruleStatistics'] as Map<String, dynamic>;
      _configStatistics = result['configStatistics'] as Map<String, dynamic>;
      _totalRounds = result['totalRounds'] as int;
      _roundDuration = result['roundDuration'] as int;

      if (result['isValid'] == false) {
        _setError(result['error'] ?? 'Failed to load challenge rule data');
      }
    } catch (e) {
      _setError('Failed to load challenge rule: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    if (_challengeId != null) {
      await loadChallengeRule(_challengeId!);
    }
  }

  /// 清除错误
  void clearError() {
    _clearError();
  }

  /// 获取排序后的挑战规则
  List<ChallengeRule> get sortedChallengeRules {
    if (_challengeRules.isEmpty) return [];
    
    final sortedRules = List<ChallengeRule>.from(_challengeRules);
    sortedRules.sort((a, b) => a.order.compareTo(b.order));
    return sortedRules;
  }

  /// 获取有效的挑战规则
  List<ChallengeRule> get validChallengeRules {
    return _challengeRules.where((rule) => rule.isValid).toList();
  }

  /// 获取下一个页面路由
  String get nextPageRoute {
    if (_challengeConfig != null && _challengeConfig!.isValid) {
      return _challengeConfig!.nextPageRoute;
    }
    return '/challenge_game'; // 默认使用挑战游戏页面
  }

  /// 验证路由有效性
  bool isRouteValid(String route) {
    return _useCase.isValidRoute(route);
  }

  /// 获取路由显示名称
  String getRouteDisplayName(String route) {
    return _useCase.getRouteDisplayName(route);
  }

  /// 获取当前路由显示名称
  String get currentRouteDisplayName {
    return getRouteDisplayName(nextPageRoute);
  }

  /// 检查挑战是否可以开始
  bool get canStartChallenge {
    return _challengeConfig?.canStartChallenge ?? false;
  }

  /// 检查挑战是否已激活
  bool get isActivated {
    return _challengeConfig?.isActivated ?? false;
  }

  /// 检查用户是否已获得资格
  bool get isQualified {
    return _challengeConfig?.isQualified ?? false;
  }

  /// 检查用户是否还有挑战次数
  bool get hasAttemptsLeft {
    return _challengeConfig?.hasAttemptsLeft ?? false;
  }

  /// 检查用户是否已用完挑战次数
  bool get hasNoAttemptsLeft {
    return _challengeConfig?.hasNoAttemptsLeft ?? false;
  }

  /// 获取剩余挑战次数
  int get allowedTimes {
    return _challengeConfig?.allowedTimes ?? 0;
  }

  /// 获取挑战状态描述
  String get challengeStatusDescription {
    if (_challengeConfig != null) {
      return _useCase.getChallengeStatusDescription(_challengeConfig!);
    }
    return 'Challenge status unknown';
  }

  /// 获取挑战配置摘要
  String get challengeConfigSummary {
    if (_challengeConfig != null) {
      return _useCase.getChallengeConfigSummary(_challengeConfig!);
    }
    return '${_totalRounds} rounds, ${_roundDuration}s per round';
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// 🎯 苹果级优化：重置所有数据状态
  void reset() {
    // 🎯 清理所有数据集合
    _challengeRules.clear();
    
    // 🎯 清理对象引用
    _challengeConfig = null;
    
    // 🎯 清理统计数据
    _ruleStatistics = null;
    _configStatistics = null;
    
    // 🎯 重置状态标志
    _isLoading = false;
    _error = null;
    _challengeId = null;
    
    // 🎯 重置配置数据
    _totalRounds = 3;
    _roundDuration = 80;
    
    print('🎯 ChallengeRuleViewModel reset completed - all data cleared');
    notifyListeners();
  }
  
  /// 🎯 苹果级优化：智能清理策略 - 保留核心数据，清理占用内存大的数据
  void smartCleanup() {
    // 🎯 保留核心数据（避免重新请求API）
    // _challengeId 保留 - 用于判断是否需要重新加载
    // _challengeRules 保留 - 核心业务数据
    // _challengeConfig 保留 - 核心配置数据
    
    // 🎯 清理占用内存大的数据
    // 保留本地弹层，无需远程数据清理
    _ruleStatistics = null;     // 统计数据可以清理
    // 教程统计已移除（仅保留本地弹层），无需清理
    _configStatistics = null;   // 配置统计可以清理
    
    // 🎯 重置状态标志
    _isLoading = false;
    _error = null;
    
    print('🎯 ChallengeRuleViewModel smart cleanup completed - core data preserved');
    notifyListeners();
  }
  
  /// 🎯 苹果级优化：检查是否需要重新加载数据
  bool get needsReload {
    // 如果没有challengeId，需要重新加载
    if (_challengeId == null) return true;
    
    // 如果没有核心数据，需要重新加载
    if (_challengeRules.isEmpty || _challengeConfig == null) return true;
    
    // 如果有错误，需要重新加载
    if (_error != null) return true;
    
    return false;
  }
  
  /// 🎯 苹果级优化：彻底清理所有资源
  @override
  void dispose() {
    // 🎯 先重置所有数据
    reset();
    
    // 🎯 清理所有集合引用
    _challengeRules = [];
    
    // 🎯 强制垃圾回收提示
    print('🎯 ChallengeRuleViewModel disposed - all resources cleaned up');
    
    super.dispose();
  }
} 