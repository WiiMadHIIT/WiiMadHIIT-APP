import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../domain/entities/training_product.dart';
import '../../domain/entities/training_item.dart';
import '../../domain/usecases/get_training_product_usecase.dart';

class TrainingListViewModel extends ChangeNotifier {
  final GetTrainingProductUseCase _getTrainingProductUseCase;

  TrainingListViewModel(this._getTrainingProductUseCase);

  // 状态变量
  TrainingProduct? _trainingProduct;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int _selectedLevel = 0;
  String? _productId;
  
  // 延迟清理相关
  Timer? _cleanupTimer;
  static const Duration _cleanupDelay = Duration(seconds: 30); // 30秒后清理

  // Getters
  TrainingProduct? get trainingProduct => _trainingProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get selectedLevel => _selectedLevel;
  String? get productId => _productId;
  
  // 计算属性
  bool get hasData => _trainingProduct != null;
  bool get hasError => _error != null;
  bool get hasAvailableTrainings => _trainingProduct?.hasAvailableTrainings ?? false;
  
  // 获取当前显示的训练列表（考虑搜索和筛选）
  List<TrainingItem> get displayTrainings {
    if (_trainingProduct == null) return [];
    
    List<TrainingItem> trainings = _trainingProduct!.activeTrainings;
    
    // 应用搜索筛选
    if (_searchQuery.isNotEmpty) {
      trainings = trainings.where((training) => 
        training.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        training.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        training.level.toString().contains(_searchQuery)
      ).toList();
    }
    
    // 应用难度等级筛选
    if (_selectedLevel > 0) {
      trainings = trainings.where((training) => training.level == _selectedLevel).toList();
    }
    
    return trainings;
  }

  // 获取页面配置
  TrainingPageConfig? get pageConfig => _trainingProduct?.pageConfig;
  
  // 获取训练统计信息
  Map<String, dynamic> get statistics {
    if (_trainingProduct == null) return {};
    
    return {
      'totalCount': _trainingProduct!.trainingCount,
      'activeCount': _trainingProduct!.activeTrainingCount,
      'totalParticipantCount': _trainingProduct!.totalParticipantCount,
    };
  }

  /// 加载训练产品数据
  Future<void> loadTrainingProduct(String productId) async {
    if (productId.isEmpty) {
      _setError('Product ID is required');
      return;
    }

    _setLoading(true);
    _clearError();
    _productId = productId; // 存储 productId

    try {
      final product = await _getTrainingProductUseCase.execute(productId);
      _trainingProduct = product;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 搜索训练项目
  void searchTrainings(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// 筛选训练项目（按难度等级）
  void filterByLevel(int level) {
    _selectedLevel = level;
    notifyListeners();
  }

  /// 清除筛选条件
  void clearFilters() {
    _searchQuery = '';
    _selectedLevel = 0;
    notifyListeners();
  }

  /// 获取推荐训练项目
  Future<List<TrainingItem>> getRecommendedTrainings(String productId) async {
    try {
      return await _getTrainingProductUseCase.getRecommendedTrainings(productId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// 获取热门训练项目
  Future<List<TrainingItem>> getPopularTrainings(String productId) async {
    try {
      return await _getTrainingProductUseCase.getPopularTrainings(productId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// 获取高完成率训练项目
  Future<List<TrainingItem>> getHighCompletionTrainings(String productId) async {
    try {
      return await _getTrainingProductUseCase.getHighCompletionTrainings(productId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// 获取训练统计信息
  Future<Map<String, dynamic>> getTrainingStatistics(String productId) async {
    try {
      return await _getTrainingProductUseCase.getTrainingStatistics(productId);
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  /// 刷新数据
  Future<void> refresh(String productId) async {
    await loadTrainingProduct(productId);
  }

  /// 清除错误
  void clearError() {
    _clearError();
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
    _trainingProduct = null;
    _error = null;
    _isLoading = false;
    _searchQuery = '';
    _selectedLevel = 0;
    _productId = null;
    notifyListeners();
  }

  /// 取消延迟清理（当用户重新访问页面时）
  void cancelCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// 检查是否有缓存数据
  bool get hasCachedData => _trainingProduct != null;

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