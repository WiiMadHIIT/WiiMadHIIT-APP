import 'package:flutter/material.dart';

class OptionsSection extends StatelessWidget {
  final VoidCallback? onLogInPressed;
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onOfficialWebsitePressed;
  final VoidCallback? onShopPressed;
  final AnimationController fadeController;
  final AnimationController slideController;

  const OptionsSection({
    super.key,
    this.onLogInPressed,
    this.onRegisterPressed,
    this.onOfficialWebsitePressed,
    this.onShopPressed,
    required this.fadeController,
    required this.slideController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: slideController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            // 标题
            Text(
              'Welcome to WiiMadHIIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'What\'s your move? 🚀',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // 主要选项：登录
            _buildPrimaryOption(
              title: 'Log In',
              subtitle: 'Back to the grind! 💪',
              icon: Icons.login_rounded,
              onTap: onLogInPressed,
              isPrimary: true,
            ),
            
            const SizedBox(height: 24),
            
            // 次要选项：注册
            _buildSecondaryOption(
              title: 'Register',
              subtitle: 'New hero in the making! ⭐',
              icon: Icons.person_add_rounded,
              onTap: onRegisterPressed,
            ),
            
            const SizedBox(height: 20),
            
            // 其他选项行
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 访问官网
                _buildTertiaryOption(
                  title: 'Official Website',
                  icon: Icons.language_rounded,
                  onTap: onOfficialWebsitePressed,
                ),
                
                const SizedBox(width: 32),
                
                // 访问商店
                _buildTertiaryOption(
                  title: 'Shop',
                  icon: Icons.shopping_bag_rounded,
                  onTap: onShopPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          // 主要按钮：白色半透明背景
          color: isPrimary 
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          // 精致边框
          border: Border.all(
            color: isPrimary 
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
            width: isPrimary ? 1.2 : 0.8,
          ),
          // 微妙阴影
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            if (isPrimary)
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, -3),
              ),
          ],
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary 
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 20),
            
            // 文本内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            
            // 箭头图标
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return _buildPrimaryOption(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      isPrimary: false,
    );
  }

  Widget _buildTertiaryOption({
    required String title,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          // 第三级选项：极简设计
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            // 图标
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
            
            const SizedBox(height: 8),
            
            // 标题
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 预设的选项页面样式
class OptionsSectionPresets {
  // 标准样式
  static OptionsSection standard({
    VoidCallback? onLogInPressed,
    VoidCallback? onRegisterPressed,
    VoidCallback? onOfficialWebsitePressed,
    VoidCallback? onShopPressed,
    required AnimationController fadeController,
    required AnimationController slideController,
  }) {
    return OptionsSection(
      onLogInPressed: onLogInPressed,
      onRegisterPressed: onRegisterPressed,
      onOfficialWebsitePressed: onOfficialWebsitePressed,
      onShopPressed: onShopPressed,
      fadeController: fadeController,
      slideController: slideController,
    );
  }
}
