import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'app_colors.dart';

/// 全局图标统一管理（大厂级/苹果风）
/// - 支持 Material、Cupertino、SVG、自定义
/// - 命名规范、分组清晰、便于多端风格切换
/// - 推荐所有业务组件/页面只用 AppIcons，不直接用原生 IconData
class AppIcons {
  // ===== Material Icons =====
  static const IconData home = Icons.home;
  static const IconData profile = Icons.person;
  static const IconData settings = Icons.settings;
  static const IconData back = Icons.arrow_back_ios_new;
  static const IconData search = Icons.search;
  static const IconData notification = Icons.notifications;
  static const IconData edit = Icons.edit;
  static const IconData add = Icons.add;
  static const IconData delete = Icons.delete;
  static const IconData camera = Icons.camera_alt;
  static const IconData photo = Icons.photo;
  static const IconData check = Icons.check_circle;
  static const IconData close = Icons.close;
  static const IconData info = Icons.info;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.error;
  static const IconData arrowForward = Icons.arrow_forward_ios;
  static const IconData arrowDown = Icons.keyboard_arrow_down;
  static const IconData arrowUp = Icons.keyboard_arrow_up;
  static const IconData menu = Icons.menu;
  static const IconData more = Icons.more_vert;
  static const IconData star = Icons.star;
  static const IconData favorite = Icons.favorite;
  static const IconData share = Icons.share;
  static const IconData lock = Icons.lock;
  static const IconData visibility = Icons.visibility;
  static const IconData visibilityOff = Icons.visibility_off;

  // ===== Cupertino Icons =====
  static const IconData cupertinoHome = CupertinoIcons.home;
  static const IconData cupertinoProfile = CupertinoIcons.person;
  static const IconData cupertinoSettings = CupertinoIcons.settings;
  static const IconData cupertinoBack = CupertinoIcons.back;
  static const IconData cupertinoSearch = CupertinoIcons.search;
  static const IconData cupertinoNotification = CupertinoIcons.bell;
  static const IconData cupertinoEdit = CupertinoIcons.pencil;
  static const IconData cupertinoAdd = CupertinoIcons.add;
  static const IconData cupertinoDelete = CupertinoIcons.delete;
  static const IconData cupertinoCamera = CupertinoIcons.camera;
  static const IconData cupertinoPhoto = CupertinoIcons.photo;
  static const IconData cupertinoCheck = CupertinoIcons.check_mark_circled;
  static const IconData cupertinoClose = CupertinoIcons.clear;
  static const IconData cupertinoInfo = CupertinoIcons.info;
  static const IconData cupertinoWarning = CupertinoIcons.exclamationmark_triangle;
  static const IconData cupertinoError = CupertinoIcons.xmark_circle;
  static const IconData cupertinoArrowForward = CupertinoIcons.right_chevron;
  static const IconData cupertinoArrowDown = CupertinoIcons.down_arrow;
  static const IconData cupertinoArrowUp = CupertinoIcons.up_arrow;
  static const IconData cupertinoMenu = CupertinoIcons.line_horizontal_3;
  static const IconData cupertinoMore = CupertinoIcons.ellipsis;
  static const IconData cupertinoStar = CupertinoIcons.star;
  static const IconData cupertinoFavorite = CupertinoIcons.heart;
  static const IconData cupertinoShare = CupertinoIcons.share;
  static const IconData cupertinoLock = CupertinoIcons.lock;
  static const IconData cupertinoVisibility = CupertinoIcons.eye;
  static const IconData cupertinoVisibilityOff = CupertinoIcons.eye_slash;

  // ===== SVG 图标（业务/品牌/多色）=====
  /// 用法：AppIcons.svg('icon_name', size: 24, color: Colors.red)
  static Widget svg(
    String name, {
    double size = 24,
    Color? color,
    BoxFit fit = BoxFit.contain,
    String? semanticLabel,
  }) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      color: color,
      fit: fit,
      semanticsLabel: semanticLabel,
    );
  }

  // ===== 动态风格切换（举例）=====
  /// 获取当前平台推荐的主图标（Material/Apple风格自动切换）
  static IconData get mainHome =>
      defaultTargetPlatform == TargetPlatform.iOS ? cupertinoHome : home;

  // ===== 品牌SVG图标（支持动态风格切换）=====
  /// WiiMadHIIT 品牌Logo SVG
  /// 用法：AppIcons.brandLogoSvg(size: 32, isActive: true)
  static Widget brandLogoSvg({double size = 32, Color? color, bool isActive = false}) {
    return svg(
      'wiimadhiit-w',
      size: size,
      color: color ?? (isActive ? AppColors.primary : AppColors.icon),
      semanticLabel: 'WiiMadHIIT Logo',
    );
  }

  // ===== 业务/品牌图标分组（举例）=====
  // static const IconData appLogo = ...;
  // static Widget appLogoSvg({double size = 32}) => svg('app_logo', size: size);

  // ===== 语义化图标（举例）=====
  // static IconData get success => check;
  // static IconData get failure => error;
}