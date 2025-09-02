import 'package:flutter/material.dart';

class BottomInfo extends StatelessWidget {
  final String? copyrightText;
  final String? mainSlogan;
  final String? subSlogan;
  final TextStyle? copyrightStyle;
  final TextStyle? mainSloganStyle;
  final TextStyle? subSloganStyle;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const BottomInfo({
    super.key,
    this.copyrightText,
    this.mainSlogan,
    this.subSlogan,
    this.copyrightStyle,
    this.mainSloganStyle,
    this.subSloganStyle,
    this.margin,
    this.padding,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 版权信息
          Text(
            copyrightText ?? '© 2025 WiiMadHIIT',
            textAlign: TextAlign.center,
            style: copyrightStyle ?? TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          
          SizedBox(height: spacing),
          
          // 主标语
          Text(
            mainSlogan ?? 'Move. Sweat. Smile. Repeat.',
            textAlign: TextAlign.center,
            style: mainSloganStyle ?? TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: spacing / 2),
          
          // 副标语
          Text(
            subSlogan ?? 'Because fitness should be fun, not boring!',
            textAlign: TextAlign.center,
            style: subSloganStyle ?? TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// 预设的底部信息样式
class BottomInfoPresets {
  // 标准样式（当前使用的样式）
  static BottomInfo standard({
    String? copyrightText,
    String? mainSlogan,
    String? subSlogan,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return BottomInfo(
      copyrightText: copyrightText,
      mainSlogan: mainSlogan,
      subSlogan: subSlogan,
      margin: margin,
      padding: padding,
      spacing: 8.0,
    );
  }
  
  // 紧凑样式
  static BottomInfo compact({
    String? copyrightText,
    String? mainSlogan,
    String? subSlogan,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return BottomInfo(
      copyrightText: copyrightText,
      mainSlogan: mainSlogan,
      subSlogan: subSlogan,
      margin: margin,
      padding: padding,
      spacing: 6.0,
    );
  }
  
  // 宽松样式
  static BottomInfo spacious({
    String? copyrightText,
    String? mainSlogan,
    String? subSlogan,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return BottomInfo(
      copyrightText: copyrightText,
      mainSlogan: mainSlogan,
      subSlogan: subSlogan,
      margin: margin,
      padding: padding,
      spacing: 12.0,
    );
  }
  
  // 品牌样式
  static BottomInfo brand({
    String? copyrightText,
    String? mainSlogan,
    String? subSlogan,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return BottomInfo(
      copyrightText: copyrightText ?? '© 2025 WiiMadHIIT',
      mainSlogan: mainSlogan ?? 'Move. Sweat. Smile. Repeat.',
      subSlogan: subSlogan ?? 'Because fitness should be fun, not boring!',
      margin: margin,
      padding: padding,
      spacing: 8.0,
      copyrightStyle: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      mainSloganStyle: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      subSloganStyle: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ),
    );
  }
  
  // 极简样式
  static BottomInfo minimal({
    String? copyrightText,
    String? mainSlogan,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return BottomInfo(
      copyrightText: copyrightText,
      mainSlogan: mainSlogan,
      subSlogan: null, // 不显示副标语
      margin: margin,
      padding: padding,
      spacing: 6.0,
      copyrightStyle: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
      ),
      mainSloganStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// 带居中包装的底部信息组件
class CenteredBottomInfo extends StatelessWidget {
  final String? copyrightText;
  final String? mainSlogan;
  final String? subSlogan;
  final EdgeInsetsGeometry? horizontalPadding;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const CenteredBottomInfo({
    super.key,
    this.copyrightText,
    this.mainSlogan,
    this.subSlogan,
    this.horizontalPadding,
    this.margin,
    this.padding,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: horizontalPadding ?? const EdgeInsets.symmetric(horizontal: 24),
        child: BottomInfo(
          copyrightText: copyrightText,
          mainSlogan: mainSlogan,
          subSlogan: subSlogan,
          margin: margin,
          padding: padding,
          spacing: spacing,
        ),
      ),
    );
  }
}

// 预设的居中底部信息样式
class CenteredBottomInfoPresets {
  // 标准居中样式（当前使用的样式）
  static CenteredBottomInfo standard({
    String? copyrightText,
    String? mainSlogan,
    String? subSlogan,
    EdgeInsetsGeometry? horizontalPadding,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return CenteredBottomInfo(
      copyrightText: copyrightText,
      mainSlogan: mainSlogan,
      subSlogan: subSlogan,
      horizontalPadding: horizontalPadding,
      margin: margin,
      padding: padding,
      spacing: 8.0,
    );
  }
  
  // 品牌居中样式
  static CenteredBottomInfo brand({
    String? copyrightText,
    String? mainSlogan,
    String? subSlogan,
    EdgeInsetsGeometry? horizontalPadding,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return CenteredBottomInfo(
      copyrightText: copyrightText ?? '© 2025 WiiMadHIIT',
      mainSlogan: mainSlogan ?? 'Move. Sweat. Smile. Repeat.',
      subSlogan: subSlogan ?? 'Because fitness should be fun, not boring!',
      horizontalPadding: horizontalPadding,
      margin: margin,
      padding: padding,
      spacing: 8.0,
    );
  }
}
