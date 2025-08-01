import 'package:audio_session/audio_session.dart';
import 'dart:io';

/// iOS 音频会话配置优化器
/// 专门为实时音频检测优化音频会话设置
class AudioSessionConfig {
  static AudioSession? _session;
  
  /// 初始化并配置音频会话
  static Future<bool> configureAudioSession() async {
    try {
      print('🎯 iOS: 开始配置音频会话...');
      
      _session = await AudioSession.instance;
      
      // 配置音频会话参数
      await _session!.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
                                      AVAudioSessionCategoryOptions.allowBluetoothA2DP |
                                      AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.measurement,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      
      print('✅ iOS: 音频会话配置成功');
      
      // 激活音频会话
      await _session!.setActive(true);
      print('✅ iOS: 音频会话激活成功');
      
      // 打印当前音频会话信息
      print('🎯 iOS: 音频会话信息:');
      print('  - 类别: ${_session!.configuration.avAudioSessionCategory}');
      print('  - 模式: ${_session!.configuration.avAudioSessionMode}');
      print('  - 选项: ${_session!.configuration.avAudioSessionCategoryOptions}');
      
      return true;
      
    } catch (e) {
      print('❌ iOS: 音频会话配置失败: $e');
      return false;
    }
  }
  
  /// 获取当前音频会话
  static AudioSession? get session => _session;
  
  /// 检查音频会话是否已激活
  static bool get isActive => _session?.isActive ?? false;
  
  /// 停用音频会话
  static Future<void> deactivate() async {
    try {
      if (_session != null && _session!.isActive) {
        await _session!.setActive(false);
        print('✅ iOS: 音频会话已停用');
      }
    } catch (e) {
      print('⚠️ iOS: 停用音频会话时出错: $e');
    }
  }
  
  /// 重新激活音频会话
  static Future<bool> reactivate() async {
    try {
      if (_session != null) {
        await _session!.setActive(true);
        print('✅ iOS: 音频会话重新激活成功');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ iOS: 重新激活音频会话失败: $e');
      return false;
    }
  }
  
  /// 获取音频会话状态信息
  static void printSessionInfo() {
    if (_session != null) {
      print('🎯 iOS: 当前音频会话状态:');
      print('  - 是否激活: ${_session!.isActive}');
      print('  - 配置: ${_session!.configuration}');
    } else {
      print('⚠️ iOS: 音频会话未初始化');
    }
  }
} 