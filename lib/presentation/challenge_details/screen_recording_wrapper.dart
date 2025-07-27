import 'dart:io';
import 'package:flutter/foundation.dart';

// 屏幕录制包装器 - 模拟器友好版本
class ScreenRecordingWrapper {
  static bool get isSupported {
    // 在模拟器上不支持屏幕录制
    if (kDebugMode && (Platform.isAndroid || Platform.isIOS)) {
      return !_isEmulator();
    }
    return true;
  }

  static bool _isEmulator() {
    // 简单的模拟器检测
    if (Platform.isAndroid) {
      return _isAndroidEmulator();
    } else if (Platform.isIOS) {
      return _isIOSEmulator();
    }
    return false;
  }

  static bool _isAndroidEmulator() {
    // 检查常见的模拟器标识
    final buildFingerprint = Platform.environment['ro.build.fingerprint'] ?? '';
    final buildModel = Platform.environment['ro.product.model'] ?? '';
    final buildManufacturer = Platform.environment['ro.product.manufacturer'] ?? '';
    
    return buildFingerprint.contains('sdk') ||
           buildFingerprint.contains('google_sdk') ||
           buildModel.contains('sdk') ||
           buildModel.contains('google_sdk') ||
           buildManufacturer.contains('unknown') ||
           buildModel.contains('Android SDK');
  }

  static bool _isIOSEmulator() {
    // iOS 模拟器检测
    return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
           Platform.environment.containsKey('SIMULATOR_HOST_HOME') ||
           Platform.environment.containsKey('SIMULATOR_UDID');
  }

  // 开始录制
  static Future<void> startRecording({
    required String name,
    String? titleNotification,
    String? messageNotification,
  }) async {
    if (!isSupported) {
      // 在模拟器上，只打印日志，不实际录制
      print('Mock: Starting screen recording: $name');
      print('Mock: Title: $titleNotification, Message: $messageNotification');
      await Future.delayed(Duration(milliseconds: 100));
      return;
    }

    // 在真机上显示提示（因为插件未安装）
    print('Device: Screen recording would start here on real device');
    print('Device: Name: $name, Title: $titleNotification, Message: $messageNotification');
    await Future.delayed(Duration(milliseconds: 100));
  }

  // 停止录制
  static Future<String> stopRecording() async {
    if (!isSupported) {
      // 在模拟器上，返回模拟路径
      print('Mock: Stopping screen recording');
      await Future.delayed(Duration(milliseconds: 100));
      return '/mock/recording/path.mp4';
    }

    // 在真机上显示提示
    print('Device: Screen recording would stop here on real device');
    await Future.delayed(Duration(milliseconds: 100));
    return '/device/recording/path.mp4';
  }
} 