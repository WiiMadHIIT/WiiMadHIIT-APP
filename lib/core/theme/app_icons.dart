import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  // Material Icons
  static const IconData home = Icons.home;
  static const IconData profile = Icons.person;
  static const IconData settings = Icons.settings;
  static const IconData back = Icons.arrow_back_ios_new;
  static const IconData search = Icons.search;

  // Cupertino Icons
  static const IconData cupertinoHome = CupertinoIcons.home;
  static const IconData cupertinoProfile = CupertinoIcons.person;
  static const IconData cupertinoSettings = CupertinoIcons.settings;
  static const IconData cupertinoBack = CupertinoIcons.back;
  static const IconData cupertinoSearch = CupertinoIcons.search;

  // SVG 图标（示例）
  static Widget svg(String name, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      color: color,
    );
  }
}
