import 'package:flutter/material.dart';

class AppColors {
  // 主色（Apple 蓝）
  static const Color primary = Color(0xFF007AFF);
  // 辅助色
  static const Color secondary = Color(0xFF34C759); // Apple 绿色
  static const Color warning = Color(0xFFFF9500);   // Apple 橙色
  static const Color error = Color(0xFFFF3B30);     // Apple 红色
  static const Color success = Color(0xFF30D158);   // Apple 成功绿

  // 灰色系
  static const Color grey1 = Color(0xFFF2F2F7); // 背景灰（浅）
  static const Color grey2 = Color(0xFFE5E5EA); // 分割线灰
  static const Color grey3 = Color(0xFFC7C7CC); // 占位/禁用
  static const Color grey4 = Color(0xFF8E8E93); // 次要文本
  static const Color grey5 = Color(0xFF3C3C43); // 主要文本

  // 纯白/黑
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // 背景色
  static const Color background = white;
  static const Color scaffoldBackground = grey1;
  static const Color divider = grey2;
}
