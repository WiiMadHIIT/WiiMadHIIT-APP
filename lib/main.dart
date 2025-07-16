import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_icons.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'presentation/profile/profile_page.dart';
import 'presentation/challenge/challenge_page.dart';
import 'presentation/home/home_page.dart';
import 'presentation/bonus/bonus_page.dart';
import 'presentation/checkin/checkin_page.dart';
import 'routes/app_routes.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wiimadhiit',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainTabPage(),
      routes: AppRoutes.routes,
    );
  }
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({Key? key}) : super(key: key);

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ChallengePage(),
    CheckinPage(),
    BonusPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _currentIndex == 1 || _currentIndex == 2
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: _buildTabBar(context, glass: true),
              ),
            )
          : _buildTabBar(context, glass: false),
    );
  }

  Widget _buildTabBar(BuildContext context, {bool glass = false}) {
    return Container(
      decoration: BoxDecoration(
        color: glass ? Colors.black.withOpacity(0.18) : AppColors.card, // 这里改为黑色半透明
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.icon,
        selectedLabelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        iconSize: 28,
        items: [
          BottomNavigationBarItem(
            icon: _SvgTabIcon(
              active: _currentIndex == 0,
              activeAsset: 'wiimadhiit-w-active',
              inactiveAsset: 'wiimadhiit-w-inactive',
            ),
            label: 'Wiimad',
          ),
          BottomNavigationBarItem(
            icon: _SvgTabIcon(
              active: _currentIndex == 1,
              activeAsset: 'pk-active',
              inactiveAsset: 'pk-inactive',
            ),
            label: 'Challenge',
          ),
          BottomNavigationBarItem(
            icon: _SvgTabIcon(
              active: _currentIndex == 2,
              activeAsset: 'training-active',
              inactiveAsset: 'training-inactive',
            ),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: _SvgTabIcon(
              active: _currentIndex == 3,
              activeAsset: 'bonus-active',
              inactiveAsset: 'bonus-inactive',
            ),
            label: 'Bonus',
          ),
          BottomNavigationBarItem(
            icon: _SvgTabIcon(
              active: _currentIndex == 4,
              activeAsset: 'profile-active',
              inactiveAsset: 'profile-inactive',
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String label;
  const _NavIcon({required this.icon, required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (active)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              Icon(
                icon,
                size: active ? 28 : 24,
                color: active ? AppColors.primary : AppColors.icon,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 新增更时尚有力量感的底部导航icon组件
class _NavIconModern extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String label;
  const _NavIconModern({required this.icon, required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: active ? 1.18 : 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (active)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.energyOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                Transform.scale(
                  scale: scale,
                  child: Icon(
                    icon,
                    size: active ? 30 : 24,
                    color: active ? AppColors.white : AppColors.icon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
          ],
        );
      },
    );
  }
}

// 新增SVG Tab Icon组件，紧凑青春有力量感
class _SvgTabIcon extends StatelessWidget {
  final bool active;
  final String activeAsset;
  final String inactiveAsset;
  const _SvgTabIcon({required this.active, required this.activeAsset, required this.inactiveAsset});

  @override
  Widget build(BuildContext context) {
    final bool isWiimadInactive = !active && inactiveAsset == 'wiimadhiit-w-inactive';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 32,
      height: 32,
      alignment: Alignment.center,
      child: isWiimadInactive
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD8D8D8),
                    shape: BoxShape.circle,
                  ),
                ),
                AppIcons.svg(
                  inactiveAsset,
                  size: 24,
                ),
              ],
            )
          : AppIcons.svg(
              active ? activeAsset : inactiveAsset,
              size: active ? 28 : 24,
            ),
    );
  }
}