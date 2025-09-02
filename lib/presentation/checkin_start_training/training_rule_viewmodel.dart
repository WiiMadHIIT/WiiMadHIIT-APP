import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../domain/entities/training_rule.dart';
import '../../domain/entities/training_config.dart';
import '../../domain/usecases/get_training_rule_usecase.dart';

class TrainingRuleViewModel extends ChangeNotifier {
  final GetTrainingRuleUseCase _useCase;

  // 状态变量
  bool _isLoading = false;
  String? _error;
  String? _trainingId;
  String? _productId;
  
  // 数据变量
  List<TrainingRule> _trainingRules = [];
  TrainingConfig? _trainingConfig;
  Map<String, dynamic>? _ruleStatistics;
  
  // 延迟清理相关
  Timer? _cleanupTimer;
  static const Duration _cleanupDelay = Duration(seconds: 30); // 30秒后清理

  TrainingRuleViewModel({
    GetTrainingRuleUseCase? useCase,
  }) : _useCase = useCase ?? GetTrainingRuleUseCase();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get trainingId => _trainingId;
  String? get productId => _productId;
  List<TrainingRule> get trainingRules => _trainingRules;
  TrainingConfig? get trainingConfig => _trainingConfig;
  Map<String, dynamic>? get ruleStatistics => _ruleStatistics;

  // 计算属性
  bool get hasData => _trainingConfig != null && _trainingConfig!.isValid;
  bool get hasError => _error != null;
  bool get hasTrainingRules => _trainingRules.isNotEmpty;
  bool get hasValidConfig => _trainingConfig != null && _trainingConfig!.isValid;

  /// 加载训练规则数据
  Future<void> loadTrainingRule(String trainingId, String productId) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _useCase.execute(trainingId, productId);
      
      _trainingId = trainingId;
      _productId = productId;
      _trainingRules = result['trainingRules'] as List<TrainingRule>;
      _trainingConfig = result['trainingConfig'] as TrainingConfig;
      _ruleStatistics = result['ruleStatistics'] as Map<String, dynamic>;

      if (result['isValid'] == false) {
        _setError(result['error'] ?? 'Failed to load training rule data');
      }
    } catch (e) {
      _setError('Failed to load training rule: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    if (_trainingId != null && _productId != null) {
      await loadTrainingRule(_trainingId!, _productId!);
    }
  }

  /// 清除错误
  void clearError() {
    _clearError();
  }

  /// 获取排序后的训练规则
  List<TrainingRule> get sortedTrainingRules {
    if (_trainingRules.isEmpty) return [];
    
    final sortedRules = List<TrainingRule>.from(_trainingRules);
    sortedRules.sort((a, b) => a.order.compareTo(b.order));
    return sortedRules;
  }

  /// 获取有效的训练规则
  List<TrainingRule> get validTrainingRules {
    return _trainingRules.where((rule) => rule.isValid).toList();
  }

  /// 获取下一个页面路由
  String get nextPageRoute {
    if (_trainingConfig != null && _trainingConfig!.isValid) {
      return _trainingConfig!.nextPageRoute;
    }
    return '/checkin_training_voice'; // 默认使用语音训练
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

  /// 检查是否需要倒计时
  bool get requiresCountdown {
    return _trainingConfig?.requiresCountdown ?? true;
  }

  /// 检查是否需要语音指导
  bool get requiresVoice {
    return _trainingConfig?.requiresVoice ?? false;
  }

  /// 检查是否直接开始训练
  bool get isDirectStart {
    return _trainingConfig?.isDirectStart ?? false;
  }

  /// 检查训练是否已激活
  bool get isActivated {
    return _trainingConfig?.isActivated ?? false;
  }

  /// 检查是否可以开始训练
  bool get canStartTraining {
    return _trainingConfig?.canStartTraining ?? false;
  }

  /// 获取激活状态文本
  String get activationStatusText {
    return _trainingConfig?.activationStatusText ?? 'Training not available';
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
    _trainingRules = [];
    _trainingConfig = null;
    _ruleStatistics = null;
    _error = null;
    _isLoading = false;
    _trainingId = null;
    _productId = null;
    notifyListeners();
  }

  /// 取消延迟清理（当用户重新访问页面时）
  void cancelCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// 检查是否有缓存数据
  bool get hasCachedData => _trainingConfig != null && _trainingConfig!.isValid;

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