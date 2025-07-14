import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_icons.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'presentation/profile/profile_page.dart';
import 'presentation/challenge/challenge_page.dart';
import 'presentation/home/home_page.dart';
import 'routes/app_routes.dart';

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

  final List<Widget> _pages = const [
    HomePage(),
    ChallengePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.card,
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
          ),
          unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _NavIconModern(
                icon: AppIcons.cupertinoHome,
                active: _currentIndex == 0,
                label: 'Home',
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _NavIconModern(
                icon: AppIcons.cupertinoStar,
                active: _currentIndex == 1,
                label: 'Challenge',
              ),
              label: 'Challenge',
            ),
            BottomNavigationBarItem(
              icon: _NavIconModern(
                icon: AppIcons.cupertinoProfile,
                active: _currentIndex == 2,
                label: 'Profile',
              ),
              label: 'Profile',
            ),
          ],
        ),
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