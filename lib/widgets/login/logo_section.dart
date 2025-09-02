import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_text_styles.dart';

class LogoSection extends StatefulWidget {
  final VoidCallback? onLogoTap;
  final EdgeInsetsGeometry? margin;
  final double logoSize;
  final double logoScale;
  final double textScale;
  final String? customSubtitle;
  final String? customHint;

  const LogoSection({
    super.key,
    this.onLogoTap,
    this.margin,
    this.logoSize = 80.0,
    this.logoScale = 0.045,
    this.textScale = 0.02,
    this.customSubtitle,
    this.customHint,
  });

  @override
  State<LogoSection> createState() => _LogoSectionState();
}

class _LogoSectionState extends State<LogoSection> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 点击Logo - 带呼吸效果
        GestureDetector(
          onTap: widget.onLogoTap,
          child: AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              final breathingScale = 1.0 + widget.logoScale * _breathingController.value;
              final shadowOpacity = 0.2 + 0.1 * _breathingController.value;
              
              return Transform.scale(
                scale: breathingScale,
                child: Container(
                  width: widget.logoSize,
                  height: widget.logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 透明过渡效果 - 从中心向外渐变
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.white.withOpacity(0.1),  // 中心微光
                        Colors.transparent,             // 中间透明
                        Colors.black.withOpacity(0.05), // 边缘微暗
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    // 精致边框
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 0.8,
                    ),
                    // 呼吸阴影效果
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(shadowOpacity),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      'assets/icons/wiimadhiit-w-red.svg',
                      width: widget.logoSize,
                      height: widget.logoSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 品牌名称 - 带呼吸效果
        AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            final breathingScale = 1.0 + widget.textScale * _breathingController.value;
            final shadowOpacity = 0.4 + 0.15 * _breathingController.value;
            
            return Transform.scale(
              scale: breathingScale,
              child: Text(
                'WiiMadHIIT',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                  fontSize: 28,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(shadowOpacity),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // 副标题 - 幽默有创意
        Text(
          widget.customSubtitle ?? 'Ready to sweat? Tap the logo! 💪',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 趣味提示
        Text(
          widget.customHint ?? 'No excuses, just results! 🚀',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 提示动画 - 更精致
        _buildPulseIndicator(),
      ],
    );
  }

  Widget _buildPulseIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + 0.2 * value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        // 重新开始动画
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}

// 带淡入和滑入动画的 LogoSection
class AnimatedLogoSection extends StatefulWidget {
  final VoidCallback? onLogoTap;
  final EdgeInsetsGeometry? margin;
  final double logoSize;
  final double logoScale;
  final double textScale;
  final String? customSubtitle;
  final String? customHint;
  final AnimationController fadeController;
  final AnimationController slideController;

  const AnimatedLogoSection({
    super.key,
    this.onLogoTap,
    this.margin,
    this.logoSize = 80.0,
    this.logoScale = 0.045,
    this.textScale = 0.02,
    this.customSubtitle,
    this.customHint,
    required this.fadeController,
    required this.slideController,
  });

  @override
  State<AnimatedLogoSection> createState() => _AnimatedLogoSectionState();
}

class _AnimatedLogoSectionState extends State<AnimatedLogoSection> {
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: widget.slideController,
          curve: Curves.easeOutCubic,
        )),
        child: LogoSection(
          onLogoTap: widget.onLogoTap,
          margin: widget.margin,
          logoSize: widget.logoSize,
          logoScale: widget.logoScale,
          textScale: widget.textScale,
          customSubtitle: widget.customSubtitle,
          customHint: widget.customHint,
        ),
      ),
    );
  }
}

