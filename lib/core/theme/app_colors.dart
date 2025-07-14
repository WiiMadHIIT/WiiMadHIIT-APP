import 'package:flutter/material.dart';

/// 极致大厂级/苹果风全局色板
class AppColors {
  // ===== 品牌主色 =====
  static const Color primary = Color(0xFFFE0C07); // 活力红
  static const Color primaryDark = Color(0xFFD00A06); // 主色深
  static const Color primaryLight = Color(0xFFFF5A55); // 主色浅

  // ===== 品牌深色/强调色 =====
  static const Color dark = Color(0xFF23191E); // 深色主色
  static const Color dark80 = Color(0xFF3A2B32); // 深色80%
  static const Color dark60 = Color(0xFF5B4751); // 深色60%
  static const Color dark40 = Color(0xFF8A7A83); // 深色40%
  static const Color dark20 = Color(0xFFC2BBC0); // 深色20%

  // ===== 品牌浅色/背景色 =====
  static const Color light = Color(0xFFFEFEFE); // 极浅白
  static const Color light80 = Color(0xFFF7F7F7); // 浅色80%
  static const Color light60 = Color(0xFFEDEDED); // 浅色60%
  static const Color light40 = Color(0xFFDADADA); // 浅色40%
  static const Color light20 = Color(0xFFBFBFBF); // 浅色20%

  // ===== 功能色/状态色 =====
  static const Color success = Color(0xFF30D158); // Apple 成功绿
  static const Color warning = Color(0xFFFF9500); // Apple 橙
  static const Color error = Color(0xFFFE0C07);   // 用主色红
  static const Color info = Color(0xFF5AC8FA);    // Apple 青蓝

  // ===== 灰阶（辅助/禁用/分割线）=====
  static const Color gray1 = Color(0xFFF5F5F7); // 极浅灰（背景）
  static const Color gray2 = Color(0xFFE5E5EA); // 卡片/分割线
  static const Color gray3 = Color(0xFFC7C7CC); // 占位/禁用
  static const Color gray4 = Color(0xFF8E8E93); // 次要文本
  static const Color gray5 = Color(0xFF3C3C43); // 主要文本

  // ===== 纯色 =====
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ===== 背景色 =====
  static const Color background = light; // 全局背景
  static const Color scaffoldBackground = gray1; // Scaffold 背景
  static const Color card = white; // 卡片背景
  static const Color dialog = white; // 弹窗背景
  static const Color sheet = white; // 底部弹窗背景

  // ===== 边框/分割线 =====
  static const Color divider = gray2;
  static const Color border = gray3;

  // ===== 文本色 =====
  static const Color textPrimary = dark; // 主要文本
  static const Color textSecondary = gray4; // 次要文本
  static const Color textDisabled = gray3; // 禁用文本
  static const Color textInverse = white; // 反色文本

  // ===== 按钮色 =====
  static const Color button = primary;
  static const Color buttonText = white;
  static const Color buttonDisabled = gray3;
  static const Color buttonTextDisabled = gray4;

  // ===== 图标色 =====
  static const Color icon = gray4;
  static const Color iconActive = primary;
  static const Color iconDisabled = gray3;

  // ===== 阴影/蒙层 =====
  static const Color shadow = Color(0x1A23191E); // 10% 深色
  static const Color overlay = Color(0x8023191E); // 50% 深色

  // ===== 选中/高亮 =====
  static const Color selected = primaryLight;
  static const Color highlight = Color(0xFFFFEAEA); // 主色高亮背景

  // ===== 运动青春活力专属色（可选扩展）=====
  static const Color energyOrange = Color(0xFFFFB300); // 活力橙
  static const Color youthBlue = Color(0xFF5AC8FA);    // 青春蓝
  static const Color vitalityGreen = Color(0xFF30D158); // 活力绿

  // ===== 其他业务色（可扩展）=====
  // static const Color xxx = ...;
}