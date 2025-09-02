import 'package:flutter/material.dart';

/// 🎯 页面可见性管理器
/// 负责管理页面切换时的视频播放状态
class PageVisibilityManager extends ChangeNotifier {
  static final PageVisibilityManager _instance = PageVisibilityManager._internal();
  factory PageVisibilityManager() => _instance;
  PageVisibilityManager._internal();

  // 页面可见性状态
  final Map<int, bool> _pageVisibilityStates = {};
  
  // 页面最后视频索引
  final Map<int, int> _pageLastVideoIndices = {};
  
  // 页面可见性变化回调
  final Map<int, Function(bool)> _visibilityCallbacks = {};

  /// 🎯 初始化页面状态
  void initializePage(int pageIndex) {
    _pageVisibilityStates[pageIndex] = false;
    _pageLastVideoIndices[pageIndex] = 0;
  }

  /// 🎯 设置页面可见性
  void setPageVisibility(int pageIndex, bool isVisible) {
    _pageVisibilityStates[pageIndex] = isVisible;
    
    // 通知回调
    if (_visibilityCallbacks.containsKey(pageIndex)) {
      _visibilityCallbacks[pageIndex]!(isVisible);
    }
    
    notifyListeners();
  }

  /// 🎯 获取页面可见性状态
  bool isPageVisible(int pageIndex) {
    return _pageVisibilityStates[pageIndex] ?? false;
  }

  /// 🎯 更新页面最后视频索引
  void updatePageLastVideoIndex(int pageIndex, int videoIndex) {
    _pageLastVideoIndices[pageIndex] = videoIndex;
    notifyListeners();
  }

  /// 🎯 获取页面最后视频索引
  int getPageLastVideoIndex(int pageIndex) {
    return _pageLastVideoIndices[pageIndex] ?? 0;
  }

  /// 🎯 注册页面可见性变化回调
  void registerVisibilityCallback(int pageIndex, Function(bool) callback) {
    _visibilityCallbacks[pageIndex] = callback;
  }

  /// 🎯 注销页面可见性变化回调
  void unregisterVisibilityCallback(int pageIndex) {
    _visibilityCallbacks.remove(pageIndex);
  }

  /// 🎯 清理所有状态
  void clear() {
    _pageVisibilityStates.clear();
    _pageLastVideoIndices.clear();
    _visibilityCallbacks.clear();
    notifyListeners();
  }
}

/// 🎯 页面可见性混入
/// 为页面提供可见性管理功能
mixin PageVisibilityMixin<T extends StatefulWidget> on State<T> {
  late final PageVisibilityManager _visibilityManager = PageVisibilityManager();
  bool _isPageVisible = false;
  int _lastVideoIndex = 0;

  /// 🎯 获取页面索引
  int get pageIndex;

  @override
  void initState() {
    super.initState();
    _visibilityManager.initializePage(pageIndex);
    _visibilityManager.registerVisibilityCallback(pageIndex, _onVisibilityChanged);
  }

  @override
  void dispose() {
    _visibilityManager.unregisterVisibilityCallback(pageIndex);
    super.dispose();
  }

  /// 🎯 页面可见性变化回调
  void _onVisibilityChanged(bool isVisible) {
    if (_isPageVisible != isVisible) {
      _isPageVisible = isVisible;
      onPageVisibilityChanged(isVisible);
    }
  }

  /// 🎯 页面可见性变化时的处理
  /// 子类可以重写此方法来实现具体的视频播放逻辑
  void onPageVisibilityChanged(bool isVisible) {
    if (isVisible) {
      // 页面变为可见时，恢复播放视频
      restoreVideoPlayback();
    } else {
      // 页面变为不可见时，暂停视频并保存状态
      pauseVideoAndSaveState();
    }
  }

  /// 🎯 恢复视频播放
  /// 子类需要重写此方法来实现具体的视频恢复逻辑
  void restoreVideoPlayback() {
    print('🎯 Page $pageIndex: Restoring video playback for index $_lastVideoIndex');
    // 子类实现具体的视频恢复逻辑
  }

  /// 🎯 暂停视频并保存状态
  /// 子类需要重写此方法来实现具体的视频暂停逻辑
  void pauseVideoAndSaveState() {
    print('🎯 Page $pageIndex: Pausing video and saving state');
    // 子类实现具体的视频暂停逻辑
  }

  /// 🎯 更新当前视频索引
  void updateCurrentVideoIndex(int videoIndex) {
    _lastVideoIndex = videoIndex;
    _visibilityManager.updatePageLastVideoIndex(pageIndex, videoIndex);
  }

  /// 🎯 获取最后视频索引
  int get lastVideoIndex => _lastVideoIndex;

  /// 🎯 检查页面是否可见
  bool get isPageVisible => _isPageVisible;
}
