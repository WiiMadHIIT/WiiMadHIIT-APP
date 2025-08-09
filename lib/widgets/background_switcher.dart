import 'package:flutter/material.dart';
import 'layout_bg_type.dart';

/// 背景切换组件
/// 
/// 提供统一的背景选择界面，支持颜色、视频、自拍、黑色背景等选项
/// 
/// ## 使用示例：
/// ```dart
/// void _onBgSwitchPressed() {
///   BackgroundSwitcher.show(
///     context: context,
///     currentBgType: bgType,
///     isInitializingCamera: _isInitializingCamera,
///     onBgTypeChanged: (LayoutBgType newType) {
///       setState(() {
///         bgType = newType;
///       });
///     },
///     onSelfiePermissionRequest: () async {
///       return await _requestCameraPermissionAndInitialize();
///     },
///     onVideoPlay: (LayoutBgType type) {
///       if (type == LayoutBgType.video && _videoReady) {
///         _videoController.play();
///         _videoFadeController.forward();
///       }
///     },
///     title: 'Background',
///   );
/// }
/// ```
/// 
/// ## 功能特性：
/// - 支持四种背景类型：颜色、视频、自拍、黑色
/// - 自拍模式支持相机权限请求和初始化状态显示
/// - 视频模式支持播放控制回调
/// - 统一的UI风格和交互体验
/// - 完全可定制的回调机制
class BackgroundSwitcher {
  /// 显示背景选择底部弹窗
  /// 
  /// [context] - 上下文
  /// [currentBgType] - 当前背景类型
  /// [isInitializingCamera] - 是否正在初始化相机（用于显示加载状态）
  /// [onBgTypeChanged] - 背景类型改变回调
  /// [onSelfiePermissionRequest] - 自拍模式权限请求回调，返回是否成功
  /// [onVideoPlay] - 视频播放回调（当选择视频背景时）
  /// [title] - 弹窗标题，默认为 'Background'
  static void show({
    required BuildContext context,
    required LayoutBgType currentBgType,
    required bool isInitializingCamera,
    required Function(LayoutBgType) onBgTypeChanged,
    required Future<bool> Function() onSelfiePermissionRequest,
    required Function(LayoutBgType) onVideoPlay,
    String title = 'Background',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽指示器
                Container(
                  width: 40, 
                  height: 4,
                  margin: EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 标题
                Text(
                  title, 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87
                  )
                ),
                SizedBox(height: 16),
                // 背景选择选项
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBgTypeOption(
                      context: context,
                      icon: Icons.format_paint_rounded,
                      label: 'Color',
                      type: LayoutBgType.color,
                      currentBgType: currentBgType,
                      isInitializingCamera: isInitializingCamera,
                      onBgTypeChanged: onBgTypeChanged,
                      onSelfiePermissionRequest: onSelfiePermissionRequest,
                      onVideoPlay: onVideoPlay,
                    ),
                    _buildBgTypeOption(
                      context: context,
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      type: LayoutBgType.video,
                      currentBgType: currentBgType,
                      isInitializingCamera: isInitializingCamera,
                      onBgTypeChanged: onBgTypeChanged,
                      onSelfiePermissionRequest: onSelfiePermissionRequest,
                      onVideoPlay: onVideoPlay,
                    ),
                    _buildBgTypeOption(
                      context: context,
                      icon: Icons.camera_front_rounded,
                      label: 'Selfie',
                      type: LayoutBgType.selfie,
                      currentBgType: currentBgType,
                      isInitializingCamera: isInitializingCamera,
                      onBgTypeChanged: onBgTypeChanged,
                      onSelfiePermissionRequest: onSelfiePermissionRequest,
                      onVideoPlay: onVideoPlay,
                    ),
                    _buildBgTypeOption(
                      context: context,
                      icon: Icons.dark_mode_rounded,
                      label: 'Black',
                      type: LayoutBgType.black,
                      currentBgType: currentBgType,
                      isInitializingCamera: isInitializingCamera,
                      onBgTypeChanged: onBgTypeChanged,
                      onSelfiePermissionRequest: onSelfiePermissionRequest,
                      onVideoPlay: onVideoPlay,
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建背景类型选项
  static Widget _buildBgTypeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required LayoutBgType type,
    required LayoutBgType currentBgType,
    required bool isInitializingCamera,
    required Function(LayoutBgType) onBgTypeChanged,
    required Future<bool> Function() onSelfiePermissionRequest,
    required Function(LayoutBgType) onVideoPlay,
  }) {
    final bool selected = currentBgType == type;
    final bool isSelfieType = type == LayoutBgType.selfie;
    final bool isLoading = isSelfieType && isInitializingCamera;
    
    return GestureDetector(
      onTap: () async {
        if (isSelfieType) {
          // 对于自拍模式，先请求相机权限
          final success = await onSelfiePermissionRequest();
          if (!success) {
            return; // 权限被拒绝或初始化失败，不切换模式
          }
        }
        
        // 关闭底部弹窗
        Navigator.of(context).pop();
        
        // 更新背景类型
        onBgTypeChanged(type);
        
        // 如果是视频类型，触发视频播放
        if (type == LayoutBgType.video) {
          onVideoPlay(type);
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(selected ? 10 : 8),
            decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: selected
                  ? [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))]
                  : [],
            ),
            child: isLoading
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        selected ? Colors.white : Colors.black54,
                      ),
                    ),
                  )
                : Icon(icon, size: 32, color: selected ? Colors.white : Colors.black54),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}