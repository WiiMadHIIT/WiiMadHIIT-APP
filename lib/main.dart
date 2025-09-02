import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_icons.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/page_visibility_manager.dart';
import 'core/auth/auth_state_manager.dart';
import 'presentation/profile/profile_page.dart';
import 'presentation/profile/profile_viewmodel.dart';
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

class _MainTabPageState extends State<MainTabPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ProfilePageState> _profilePageKey = GlobalKey<ProfilePageState>();
  
  // 统一认证状态管理器
  late final AuthStateManager _authManager = AuthStateManager();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _pages = [
      HomePage(),
      ChallengePage(),
      CheckinPage(),
      BonusPage(),
      ProfilePage(key: _profilePageKey),
    ];
    
    // 初始化认证状态管理器
    _authManager.initialize();
    
    // 监听认证状态变化，同步Tab状态
    _authManager.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  /// 认证状态变化回调
  void _onAuthStateChanged() {
    // 大厂级别：简化逻辑，认证状态变化时无需特殊处理
    // Tab认证状态会在需要时自动检查
    print('🔐 MainTabPage: 认证状态变化，无需特殊处理');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 让tabbar底部区域透明,内容延申到tabbar底部
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildAdaptiveTabBar(context),
    );
  }

  Widget _buildAdaptiveTabBar(BuildContext context) {
    final bool isWiimadActive = _currentIndex == 0;
    final bool isProfileActive = _currentIndex == 4;
    final bool isLightTabActive = _currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3;

    // 当切换到 Wiimad tab 时启动动画
    if (isWiimadActive) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              // ====== 毛玻璃效果的核心 ======
              // 这里通过 BackdropFilter + sigmaX/Y 实现底部导航栏的毛玻璃模糊
              filter: ImageFilter.blur(
                sigmaX: isProfileActive ? 0 : (isWiimadActive ? 25 : 28),
                sigmaY: isProfileActive ? 0 : (isWiimadActive ? 25 : 28),
              ),
              // ===========================
              child: Container(
                decoration: BoxDecoration(
                  color: isProfileActive
                      ? AppColors.card
                      : (isWiimadActive ? Colors.black.withOpacity(0) : Colors.transparent),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    // 🎯 页面切换逻辑
                    _handlePageChange(index);
                  },
                  selectedItemColor: isWiimadActive 
                      ? AppColors.primary 
                      : AppColors.primary,
                  unselectedItemColor: isLightTabActive
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.icon,
                  selectedLabelStyle: AppTextStyles.labelLarge.copyWith(
                    color: isWiimadActive ? AppColors.primary : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    shadows: isWiimadActive ? [
                      Shadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ] : null,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
                    color: isLightTabActive
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  iconSize: 28,
                  items: [
                    BottomNavigationBarItem(
                      icon: _AdaptiveTabIcon(
                        active: _currentIndex == 0,
                        activeAsset: 'wiimadhiit-w-active',
                        inactiveAsset: 'wiimadhiit-w-inactive',
                        isWiimadActive: isWiimadActive,
                      ),
                      label: 'WiiMad',
                    ),
                    BottomNavigationBarItem(
                      icon: _AdaptiveTabIcon(
                        active: _currentIndex == 1,
                        activeAsset: 'pk-active',
                        inactiveAsset: 'pk-inactive',
                        isWiimadActive: isWiimadActive,
                      ),
                      label: 'Challenge',
                    ),
                    BottomNavigationBarItem(
                      icon: _AdaptiveTabIcon(
                        active: _currentIndex == 2,
                        activeAsset: 'training-active',
                        inactiveAsset: 'training-inactive',
                        isWiimadActive: isWiimadActive,
                      ),
                      label: 'Check-in',
                    ),
                    BottomNavigationBarItem(
                      icon: _AdaptiveTabIcon(
                        active: _currentIndex == 3,
                        activeAsset: 'bonus-active',
                        inactiveAsset: 'bonus-inactive',
                        isWiimadActive: isWiimadActive,
                      ),
                      label: 'Bonus',
                    ),
                    BottomNavigationBarItem(
                      icon: _AdaptiveTabIcon(
                        active: _currentIndex == 4,
                        activeAsset: 'profile-active',
                        inactiveAsset: 'profile-inactive',
                        isWiimadActive: isWiimadActive,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎯 处理页面切换逻辑
  void _handlePageChange(int newIndex) async {
    final int previousIndex = _currentIndex;
    
    // 大厂级别：Profile页面需要认证检查
    if (newIndex == 4) { // Profile tab
      final isAuthenticated = await _authManager.checkPageAuth(AppRoutes.profile);
      if (!isAuthenticated) {
        // 未认证，跳转登录页面
        print('🔐 MainTabPage: Profile页面需要认证，跳转登录页面');
        Navigator.of(context).pushNamed(AppRoutes.login);
        return; // 阻止Tab切换
      }
    }
    
    // 认证通过或不需要认证，正常切换Tab
    // 使用页面可见性管理器通知页面切换
    final visibilityManager = PageVisibilityManager();
    visibilityManager.setPageVisibility(previousIndex, false); // 页面隐藏
    visibilityManager.setPageVisibility(newIndex, true);       // 页面显示
    
    setState(() {
      _currentIndex = newIndex;
    });
    
    // 大厂级别：当切换到Profile页面时，智能刷新数据
    if (newIndex == 4) {
      Future.delayed(const Duration(milliseconds: 100), () {
        // 重置滑动提示
        _profilePageKey.currentState?.resetScrollHint();
        
        // 大厂级别：调用ProfilePage的内部方法进行智能刷新
        _profilePageKey.currentState?.smartRefreshProfileData();
      });
    }
  }


}

// 自适应 Tab Icon 组件
class _AdaptiveTabIcon extends StatelessWidget {
  final bool active;
  final String activeAsset;
  final String inactiveAsset;
  final bool isWiimadActive;

  const _AdaptiveTabIcon({
    required this.active,
    required this.activeAsset,
    required this.inactiveAsset,
    required this.isWiimadActive,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWiimadInactive = !active && inactiveAsset == 'wiimadhiit-w-inactive';
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 32,
      height: 32,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆圈 - 根据 Wiimad 状态调整
          if (active)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isWiimadActive ? 40 : 36,
              height: isWiimadActive ? 40 : 36,
              decoration: BoxDecoration(
                gradient: isWiimadActive
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isWiimadActive ? null : AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: isWiimadActive
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.4),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: isWiimadActive
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.18),
                    blurRadius: isWiimadActive ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          
          // Wiimad 特殊处理
          if (isWiimadInactive)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isWiimadActive
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFD8D8D8),
                shape: BoxShape.circle,
                border: isWiimadActive
                    ? Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      )
                    : null,
              ),
            ),
          
          // Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: isWiimadInactive
                ? AppIcons.svg(
                    inactiveAsset,
                    size: isWiimadActive ? 22 : 24,
                  )
                : AppIcons.svg(
                    active ? activeAsset : inactiveAsset,
                    size: active 
                        ? (isWiimadActive ? 30 : 28)
                        : (isWiimadActive ? 24 : 24),
                  ),
          ),
        ],
      ),
    );
  }
}
