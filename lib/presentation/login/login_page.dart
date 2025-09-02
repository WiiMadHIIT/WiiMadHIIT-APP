import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../widgets/floating_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/auth_state_manager.dart';
import '../../widgets/login/logo_section.dart';
import '../../widgets/login/glass_overlay.dart';
import '../../widgets/login/bottom_info.dart';
import '../../widgets/login/options_section.dart';
import '../../routes/app_routes.dart';
import 'login_viewmodel.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/usecases/auth/send_login_code_usecase.dart';
import '../../domain/usecases/auth/verify_login_code_usecase.dart';
import '../../domain/usecases/auth/send_register_code_usecase.dart';
import '../../domain/usecases/auth/verify_register_code_usecase.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/api/auth_api.dart';
import '../../data/error_management/auth_error_mapper.dart';

class LoginPage extends StatefulWidget {
  
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthStateManager _authManager = AuthStateManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        authService: AuthService(),
        sendLoginCodeUseCase: SendLoginCodeUseCase(AuthRepository(AuthApi())),
        verifyLoginCodeUseCase: VerifyLoginCodeUseCase(AuthRepository(AuthApi())),
        sendRegisterCodeUseCase: SendRegisterCodeUseCase(AuthRepository(AuthApi())),
        verifyRegisterCodeUseCase: VerifyRegisterCodeUseCase(AuthRepository(AuthApi())),
      ),
      child: const _LoginPageContent(),
    );
  }
}

class _LoginPageContent extends StatefulWidget {
  const _LoginPageContent({Key? key}) : super(key: key);

  @override
  State<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<_LoginPageContent> with TickerProviderStateMixin {
  // 认证状态管理器
  late final AuthStateManager _authManager = AuthStateManager();
  
  // 视频控制器（默认 + 当前使用）
  VideoPlayerController? _defaultVideoController;
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  // 可选：远程背景视频地址（为空则始终使用默认）
  String? _remoteVideoUrl; // e.g. https://cdn.example.com/login_bg.mp4
  
  // 页面状态管理
  LoginStep _currentStep = LoginStep.logo;
  
  // 动画控制器
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  // 表单控制器
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _activationCodeController = TextEditingController();

  
  // 表单状态
  bool _isEmailValid = false;
  bool _isCodeValid = false;
  bool _isLoading = false;
  
  // 登录与注册验证码发送与倒计时分离
  bool _isLoginCodeSent = false;
  bool _isRegisterCodeSent = false;
  int _loginCountdown = 0;
  int _registerCountdown = 0;
  Timer? _loginCountdownTimer;
  Timer? _registerCountdownTimer;
  Timer? _bannerTimer;
  
  bool _isActivationCodeValid = false;
  bool _isActivationLoading = false;
  
  // 注册表单状态
  bool _isRegisterLoading = false;
  
  // 计算表单区域的自适应宽度，避免小屏或分屏下横向溢出
  double _formWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 32.0; // Safe padding
    const double minWidth = 260.0;
    const double maxWidth = 420.0;
    final double target = screenWidth - horizontalPadding;
    return target.clamp(minWidth, maxWidth).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeVideoBasedOnOrientation();
  }

  void _initializeControllers() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // 启动初始动画，让logo页面显示
    _fadeController.forward();
    _slideController.forward();
  }

  /// 初始化视频：先用本地默认视频，若远程视频可用且加载成功则切换为远程
  Future<void> _initializeVideoBasedOnOrientation() async {
    try {
      // 1) 初始化默认本地视频
      _defaultVideoController = VideoPlayerController.asset('assets/video/video1.mp4')
        ..setLooping(true)
        ..setVolume(0.0);
      await _defaultVideoController!.initialize();
      if (!mounted) return;
      _videoController = _defaultVideoController;
      _videoReady = true;
      _videoController!.play();
      setState(() {});

      // 2) 可选：异步加载远程视频，加载成功后平滑切换
      if (_remoteVideoUrl != null && _remoteVideoUrl!.isNotEmpty) {
        _initializeRemoteVideoAsync(_remoteVideoUrl!);
      }
    } catch (e) {
      print('❌ Login default video init error: $e');
      // 失败时保持无视频/黑底，避免崩溃
    }
  }

  /// 异步加载远程视频并切换
  Future<void> _initializeRemoteVideoAsync(String url) async {
    VideoPlayerController? remoteController;
    try {
      remoteController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..setLooping(true)
        ..setVolume(0.0);
      await remoteController.initialize();
      if (!mounted) {
        remoteController.dispose();
        return;
      }
      // 切换到远程视频
      if (_videoController?.value.isPlaying == true) {
        _videoController!.pause();
      }
      _videoController = remoteController;
      _videoReady = true;
      _videoController!.play();
      setState(() {});
      // 防止重复释放
      remoteController = null;
    } catch (e) {
      print('❌ Login remote video init error: $e');
      // 保持默认视频播放
      if (remoteController != null) {
        try { remoteController.dispose(); } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _activationCodeController.dispose();

    // 清理所有定时器
    _loginCountdownTimer?.cancel();
    _registerCountdownTimer?.cancel();
    _bannerTimer?.cancel();
    
    // 重置状态
    _isSendingCode = false;
    _isLoginCodeSent = false;
    _isRegisterCodeSent = false;
    _loginCountdown = 0;
    _registerCountdown = 0;
    
    try {
      if (_videoController != null && _videoController != _defaultVideoController) {
        _videoController!.dispose();
      }
      _defaultVideoController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onLogoTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
      _transitionToOptionsStep();
    });
  }

  void _transitionToOptionsStep() {
    setState(() {
      _currentStep = LoginStep.options;
    });
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _transitionToEmailStep() {
    setState(() {
      _currentStep = LoginStep.email;
      // 重置登录相关状态
      _isLoginCodeSent = false;
      _loginCountdown = 0;
      _isSendingCode = false;
      // 重置邮箱验证状态
      _isEmailValid = false;
    });
    
    // 清空邮箱输入框
    _emailController.clear();
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _transitionToRegisterStep() {
    setState(() {
      _currentStep = LoginStep.register;
      // 重置注册相关状态
      _isRegisterCodeSent = false;
      _registerCountdown = 0;
      _isSendingCode = false;
      // 重置邮箱验证状态
      _isEmailValid = false;
    });
    
    // 清空邮箱输入框
    _emailController.clear();
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _isEmailValid = _isValidEmail(value);
    });
    try {
      final vm = Provider.of<LoginViewModel>(context, listen: false);
      if (_currentStep == LoginStep.register) {
        vm.setRegisterEmail(value);
      } else {
        vm.setEmail(value);
      }
    } catch (_) {}
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _onCodeChanged(String value) {
    setState(() {
      _isCodeValid = value.length == 6;
    });
    try {
      final vm = Provider.of<LoginViewModel>(context, listen: false);
      if (_currentStep == LoginStep.register) {
        vm.setRegisterCode(value);
      } else {
        vm.setCode(value);
      }
    } catch (_) {}
  }



  void _onActivationCodeChanged(String value) {
    setState(() {
      _isActivationCodeValid = value.length >= 8;
    });
    try {
      final vm = Provider.of<LoginViewModel>(context, listen: false);
      vm.setActivationCode(value);
    } catch (_) {}
  }

  Future<void> _sendVerificationCode() async {
    // 根据当前步骤分发到登录或注册通道
    if (_currentStep == LoginStep.register) {
      await _sendRegisterCode();
    } else {
      await _sendLoginCode();
    }
  }

  // 登录通道：发送验证码并启动登录倒计时
  Future<void> _sendLoginCode() async {
    if (!_isEmailValid) return;
    
    try {
      final vm = Provider.of<LoginViewModel>(context, listen: false);
      await vm.sendLoginCode();
      if (!mounted) return;
      
      // 检查是否有错误
      if (vm.errorCode != null && vm.errorCode != 'A200') {
        // 有错误，显示错误信息
        final errorMessage = vm.userFriendlyMessage ?? vm.errorMessage ?? 'Failed to send code';
        final errorCode = vm.errorCode;
        
        // 使用错误映射工具获取显示样式
        final errorStyle = AuthErrorMapper.getErrorStyle(errorCode ?? '');
        final bannerColor = _getBannerColor(errorStyle['color']);
        final bannerIcon = _getBannerIcon(errorStyle['icon']);
        final bannerDuration = Duration(seconds: errorStyle['duration'] ?? 4);
        
        // 显示错误信息
        _showTopBanner(
          errorMessage,
          bgColor: bannerColor,
          icon: bannerIcon,
          duration: bannerDuration,
        );
        
        // 如果有错误码，在控制台输出
        if (errorCode != null) {
          print('Error Code: $errorCode');
          print('Error Message: ${vm.errorMessage}');
          print('User Friendly Message: ${vm.userFriendlyMessage}');
        }
        
        // 错误后重置发送状态，允许用户重试
        setState(() { 
          _isLoginCodeSent = false;
          _loginCountdown = 0;
        });
        return;
      }
      
      // 没有错误，继续正常流程
      setState(() {
        _isLoginCodeSent = true;
      });
      
      // 启动倒计时
      final seconds = vm.resendCountdown > 0 ? vm.resendCountdown : 60;
      _beginCountdown(forRegister: false, seconds: seconds);
      
      print('✅ 登录验证码发送成功，启动倒计时: ${seconds}s');
      
    } catch (e) {
      if (!mounted) return;
      
      // 处理异常情况
      _showTopBanner(
        'An unexpected error occurred',
        bgColor: Colors.red,
        icon: Icons.error_outline,
        duration: const Duration(seconds: 4),
      );
      
      print('❌ Unexpected error in _sendLoginCode: $e');
      
      // 异常后重置发送状态
      setState(() { 
        _isLoginCodeSent = false;
        _loginCountdown = 0;
      });
    }
  }

  // 注册通道：发送验证码并启动注册倒计时
  Future<void> _sendRegisterCode() async {
    if (!_isEmailValid) return;
    
    try {
      final vm = Provider.of<LoginViewModel>(context, listen: false);
      await vm.sendRegisterCode();
      if (!mounted) return;
      
      // 检查是否有错误
      if (vm.errorCode != null && vm.errorCode != 'A200') {
        // 有错误，显示错误信息
        final errorMessage = vm.userFriendlyMessage ?? vm.errorMessage ?? 'Failed to send code';
        final errorCode = vm.errorCode;
        
        // 使用错误映射工具获取显示样式
        final errorStyle = AuthErrorMapper.getErrorStyle(errorCode ?? '');
        final bannerColor = _getBannerColor(errorStyle['color']);
        final bannerIcon = _getBannerIcon(errorStyle['icon']);
        final bannerDuration = Duration(seconds: errorStyle['duration'] ?? 4);
        
        // 显示错误信息
        _showTopBanner(
          errorMessage,
          bgColor: bannerColor,
          icon: bannerIcon,
          duration: bannerDuration,
        );
        
        // 如果有错误码，在控制台输出
        if (errorCode != null) {
          print('Error Code: $errorCode');
          print('Error Message: ${vm.errorMessage}');
          print('User Friendly Message: ${vm.userFriendlyMessage}');
        }
        
        // 错误后重置发送状态，允许用户重试
        setState(() { 
          _isRegisterCodeSent = false;
          _registerCountdown = 0;
        });
        return;
      }
      
      // 没有错误，继续正常流程
      setState(() {
        _isRegisterCodeSent = true;
      });
      
      // 启动倒计时
      final seconds = vm.resendCountdown > 0 ? vm.resendCountdown : 60;
      _beginCountdown(forRegister: true, seconds: seconds);
      
      print('✅ 注册验证码发送成功，启动倒计时: ${seconds}s');
      
    } catch (e) {
      if (!mounted) return;
      
      // 处理异常情况
      _showTopBanner(
        'An unexpected error occurred',
        bgColor: Colors.red,
        icon: Icons.error_outline,
        duration: const Duration(seconds: 4),
      );
      
      print('❌ Unexpected error in _sendRegisterCode: $e');
      
      // 异常后重置发送状态
      setState(() { 
        _isRegisterCodeSent = false;
        _registerCountdown = 0;
      });
    }
  }

  // 启动倒计时（登录/注册独立）
  void _beginCountdown({required bool forRegister, required int seconds}) {
    if (forRegister) {
      _registerCountdownTimer?.cancel();
      setState(() { 
        _registerCountdown = seconds;
        _isRegisterCodeSent = true;
      });
      
      if (_registerCountdown <= 0) {
        setState(() { 
          _isRegisterCodeSent = false; 
          _registerCountdown = 0; 
        });
        return;
      }
      
      _registerCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) { 
          timer.cancel(); 
          return; 
        }
        
        setState(() {
          if (_registerCountdown <= 1) {
            _isRegisterCodeSent = false;
            _registerCountdown = 0;
          } else {
            _registerCountdown -= 1;
          }
        });
        
        if (_registerCountdown <= 0) {
          timer.cancel();
        }
      });
      
      print('⏰ 注册验证码倒计时启动: ${seconds}s');
      
    } else {
      _loginCountdownTimer?.cancel();
      setState(() { 
        _loginCountdown = seconds;
        _isLoginCodeSent = true;
      });
      
      if (_loginCountdown <= 0) {
        setState(() { 
          _isLoginCodeSent = false; 
          _loginCountdown = 0; 
        });
        return;
      }
      
      _loginCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) { 
          timer.cancel(); 
          return; 
        }
        
        setState(() {
          if (_loginCountdown <= 1) {
            _isLoginCodeSent = false;
            _loginCountdown = 0;
          } else {
            _loginCountdown -= 1;
          }
        });
        
        if (_loginCountdown <= 0) {
          timer.cancel();
        }
      });
      
      print('⏰ 登录验证码倒计时启动: ${seconds}s');
    }
  }

  // 兼容保留：不再直接启动倒计时，避免误用
  void _startCountdown() {
    return;
  }

  Future<void> _onLoginPressed() async {
    if (!_isEmailValid || !_isCodeValid) return;
    
    setState(() {
      _isLoading = true;
    });
    final vm = Provider.of<LoginViewModel>(context, listen: false);
    try {
      final success = await vm.verifyLoginCode();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
              if (success) {
          _showTopBanner('Login successful! Welcome back! 🎉',
              bgColor: Colors.green, icon: Icons.check_circle);
          
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            // 大厂级别：简化逻辑，登录成功后直接返回上一页
            await _authManager.handleLoginSuccess(context);
          }
        } else {
        _showTopBanner('Login failed: ${vm.errorMessage ?? 'Invalid code'}', 
            bgColor: Colors.red, icon: Icons.error_outline);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showTopBanner('Login failed: $e', bgColor: Colors.red, icon: Icons.error_outline);
    }
  }

  // 顶部提示（使用 MaterialBanner，避免覆盖底部 Tab）
  void _showTopBanner(String message, {required Color bgColor, required IconData icon, Duration duration = const Duration(seconds: 2)}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    // 确保只有一个Banner
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(message,
            style: TextStyle(
              color: bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
        ),
        leading: Icon(icon, color: bgColor),
        backgroundColor: bgColor.withOpacity(0.12),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => messenger.clearMaterialBanners(),
            child: const Text('DISMISS'),
          ),
        ],
      ),
    );
    // 重置并启动自动关闭计时器，避免多个Banner相互影响
    _bannerTimer?.cancel();
    _bannerTimer = Timer(duration, () {
      if (!mounted) return;
      final m = ScaffoldMessenger.maybeOf(context);
      m?.clearMaterialBanners();
    });
  }

  void _onRegisterPressed() {
    _transitionToActivationStep();
  }

  void _transitionToActivationStep() {
    setState(() {
      _currentStep = LoginStep.activation;
    });
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 视频背景
          _buildVideoBackground(),
          
          // 玻璃遮罩
          _buildGlassOverlay(),
          
          // 内容区域
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (!_videoReady || _videoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  Widget _buildGlassOverlay() {
    return GlassOverlayPresets.dewdrop();
  }

  Widget _buildContent() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 返回按钮 - 左上角
                    _buildBackButton(),
                    
                    const Spacer(),
                    
                    // Logo区域
                    if (_currentStep == LoginStep.logo) _buildLogoSection(),
                    
                    // 选项页面
                    if (_currentStep == LoginStep.options) OptionsSectionPresets.standard(
                      onLogInPressed: _transitionToEmailStep,
                      onRegisterPressed: _onRegisterPressed,
                      onOfficialWebsitePressed: _launchOfficialWebsite,
                      onShopPressed: _launchShopPage,
                      fadeController: _fadeController,
                      slideController: _slideController,
                    ),
                    
                    // 登录表单区域
                    if (_currentStep == LoginStep.email) _buildLoginForm(),
                    
                    // 激活码验证区域
                    if (_currentStep == LoginStep.activation) _buildActivationForm(),
                    
                    // 注册表单区域
                    if (_currentStep == LoginStep.register) _buildRegisterForm(),
                    
                    const Spacer(),
                    
                    // 底部信息 - 居中显示
                    _buildBottomInfo(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedLogoSection(
      onLogoTap: _onLogoTap,
      logoSize: 80.0,
      logoScale: 0.045,
      textScale: 0.02,
      customSubtitle: 'Ready to sweat? Tap the logo! 💪',
      customHint: 'No excuses, just results! 🚀',
      fadeController: _fadeController,
      slideController: _slideController,
    );
  }



  Widget _buildLoginForm() {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            // 顶部标题区
            _buildLoginHeader(),
            
            const SizedBox(height: 48),
            
            // 邮箱输入框
            _buildCompactEmailInput(),
            
            const SizedBox(height: 24),
            
            // 验证码输入框
            _buildCompactCodeInput(),
            
            const SizedBox(height: 32),
            
            // 登录按钮
            _buildCompactLoginButton(),
            
            const SizedBox(height: 32),
            
            // 底部导航区
            _buildLoginFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Column(
      children: [
        // 主标题
        Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // 副标题
        Text(
          'Ready to sweat again? 🔥',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompactEmailInput() {
    return Container(
      width: _formWidth(context),
      decoration: BoxDecoration(
        // 悬浮在视频背景上的半透明背景
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        // 精致的白色边框
        border: Border.all(
          color: _isEmailValid 
              ? Colors.green.withOpacity(0.6)
              : Colors.white.withOpacity(0.3),
          width: 1.2,
        ),
        // 微妙阴影
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        onChanged: _onEmailChanged,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: _isEmailValid
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green.withOpacity(0.8),
                  size: 24,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCompactCodeInput() {
    return Container(
      width: _formWidth(context),
      decoration: BoxDecoration(
        // 悬浮在视频背景上的半透明背景
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        // 精致的白色边框
        border: Border.all(
          color: _isCodeValid 
              ? Colors.green.withOpacity(0.6)
              : Colors.white.withOpacity(0.3),
          width: 1.2,
        ),
        // 微妙阴影
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 验证码输入框
          TextField(
            controller: _codeController,
            onChanged: _onCodeChanged,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'Enter 6-digit code',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              counterText: '',
              suffixIcon: _isCodeValid
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green.withOpacity(0.8),
                      size: 24,
                    )
                  : null,
            ),
          ),
          
          // 发送验证码按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // 左侧区域自适应，避免与右侧图标相互挤压
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: (!((_currentStep == LoginStep.register) ? _isRegisterCodeSent : _isLoginCodeSent))
                        ? GestureDetector(
                            onTap: (_isEmailValid && !_isSendingCode) ? _onSendCodePressed : null,
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedScale(
                              scale: (_isEmailValid && !_isSendingCode) ? _sendCodeScale : 1.0,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOutCubic,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 24),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isSendingCode)
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white.withOpacity(0.6),
                                            ),
                                          ),
                                        )
                                      else
                                        Text(
                                          'Send Code',
                                          style: TextStyle(
                                            color: _isEmailValid 
                                                ? Colors.white.withOpacity(0.8)
                                                : Colors.white.withOpacity(0.4),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Text(
                            'Resend in ${(_currentStep == LoginStep.register) ? _registerCountdown : _loginCountdown}s',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                  ),
                ),
                
                // 右侧状态指示图标
                if (_isCodeValid)
                  Icon(
                    Icons.verified,
                    color: Colors.green.withOpacity(0.8),
                    size: 20,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLoginButton() {
    final bool canLogin = _isEmailValid && _isCodeValid && !_isLoading;
    
    return Container(
      width: _formWidth(context),
      height: 56,
      child: ElevatedButton(
        onPressed: canLogin ? _onLoginPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canLogin 
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
          foregroundColor: canLogin 
              ? Colors.black
              : Colors.white.withOpacity(0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: canLogin 
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    canLogin ? Colors.black : Colors.white.withOpacity(0.6),
                  ),
                ),
              )
            : Text(
                'Log In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  Widget _buildLoginFooter() {
    return Column(
      children: [
        // 返回上一页按钮
        GestureDetector(
          onTap: () {
            _transitionToOptionsStep();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Options',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 注册链接
        TextButton(
          onPressed: _onRegisterPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Don\'t have an account? Register',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }



  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8),
        child: GestureDetector(
          onTap: () {
            _handleBackNavigation();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  /// 大厂级别：智能返回导航处理
  void _handleBackNavigation() {
    // 检查是否可以返回上一页
    if (Navigator.of(context).canPop()) {
      // 可以返回，执行返回操作
      Navigator.of(context).pop();
    } else {
      // 无法返回（没有上一页），跳转到主页
      _navigateToHome();
    }
  }

  /// 跳转到主页
  void _navigateToHome() {
    try {
      // 使用 pushReplacementNamed 避免在导航栈中留下登录页面
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      // 如果路由跳转失败，尝试使用 pushNamed
      try {
        Navigator.of(context).pushNamed('/');
      } catch (e2) {
        // 如果所有路由都失败，记录错误日志
        print('❌ 无法跳转到主页: $e2');
        // 作为最后的备选方案，尝试返回上一页
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }



  Widget _buildActivationForm() {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            // 顶部标题区
            _buildActivationHeader(),
            
            const SizedBox(height: 48),
            
            // 激活码输入框
            _buildActivationCodeInput(),
            
            const SizedBox(height: 32),
            
            // 提交按钮
            _buildActivationSubmitButton(),
            
            const SizedBox(height: 32),
            
            // 底部导航区
            _buildActivationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivationHeader() {
    return Column(
      children: [
        // 主标题
        Text(
          'Activate Your Device',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // 副标题
        Text(
          'Enter your activation code to continue',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // 提示信息
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your activation code is your Amazon order number',
                  style: TextStyle(
                    color: Colors.blue.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivationCodeInput() {
    return Container(
      width: _formWidth(context),
      decoration: BoxDecoration(
        // 悬浮在视频背景上的半透明背景
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        // 精致的白色边框
        border: Border.all(
          color: _isActivationCodeValid 
              ? Colors.green.withOpacity(0.6)
              : Colors.white.withOpacity(0.3),
          width: 1.2,
        ),
        // 微妙阴影
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _activationCodeController,
        onChanged: _onActivationCodeChanged,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Enter activation code',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: _isActivationCodeValid
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green.withOpacity(0.8),
                  size: 24,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildActivationSubmitButton() {
    final bool canSubmit = _isActivationCodeValid && !_isActivationLoading;
    
    return Container(
      width: _formWidth(context),
      height: 56,
      child: ElevatedButton(
        onPressed: canSubmit ? _onActivationCodeSubmitted : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit 
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
          foregroundColor: canSubmit 
              ? Colors.black
              : Colors.white.withOpacity(0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: canSubmit 
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        child: _isActivationLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    canSubmit ? Colors.black : Colors.white.withOpacity(0.6),
                  ),
                ),
              )
            : Text(
                'Submit for Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  Widget _buildActivationFooter() {
    return Column(
      children: [
        // 返回上一页按钮
        GestureDetector(
          onTap: () {
            _transitionToOptionsStep();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Options',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            // 顶部标题区
            _buildRegisterHeader(),
            
            const SizedBox(height: 48),
            
            // 邮箱输入框
            _buildCompactEmailInput(),
            
            const SizedBox(height: 24),
            
            // 验证码输入框
            _buildCompactCodeInput(),
            
            const SizedBox(height: 32),
            
            // 注册按钮
            _buildRegisterButton(),
            
            const SizedBox(height: 32),
            
            // 底部导航区
            _buildRegisterFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterHeader() {
    return Column(
      children: [
        // 主标题
        Text(
          'Create Your Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // 副标题
        Text(
          'Join the WiiMadHIIT family today! 🚀',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }



  Widget _buildRegisterButton() {
    final bool canRegister = _isEmailValid && _isCodeValid && !_isRegisterLoading;
    
    return Container(
      width: _formWidth(context),
      height: 56,
      child: ElevatedButton(
        onPressed: canRegister ? _onRegisterButtonPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canRegister 
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
          foregroundColor: canRegister 
              ? Colors.black
              : Colors.white.withOpacity(0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: canRegister 
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        child: _isRegisterLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    canRegister ? Colors.black : Colors.white.withOpacity(0.6),
                  ),
                ),
              )
            : Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  Widget _buildRegisterFooter() {
    return Column(
      children: [
        // 返回上一页按钮
        GestureDetector(
          onTap: () {
            _transitionToActivationStep();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Activation',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 登录链接
        TextButton(
          onPressed: _transitionToEmailStep,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Already have an account? Log In',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _launchOfficialWebsite() async {
    final Uri url = Uri.parse('https://www.wiimadhiit.com/');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        _showTopBanner('Oops! Website is playing hide and seek 🕵️',
            bgColor: Colors.orange, icon: Icons.info_outline);
      }
    } catch (e) {
      if (mounted) {
        _showTopBanner('Website got stage fright! 😅',
            bgColor: Colors.orange, icon: Icons.info_outline);
      }
    }
  }

  Future<void> _launchShopPage() async {
    final Uri url = Uri.parse('https://www.wiimadhiit.com/equipment');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        _showTopBanner('Shop is taking a coffee break! ☕',
            bgColor: Colors.orange, icon: Icons.info_outline);
      }
    } catch (e) {
      if (mounted) {
        _showTopBanner('Shop got lost in the mall! 🛍️',
            bgColor: Colors.red, icon: Icons.error_outline);
      }
    }
  }

  Future<void> _onActivationCodeSubmitted() async {
    if (!_isActivationCodeValid) return;
    
    setState(() {
      _isActivationLoading = true;
    });
    
    // 模拟激活码验证
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isActivationLoading = false;
      });
      
      // 激活码验证成功后跳转到注册表单
      _transitionToRegisterStep();
    }
  }

  Future<void> _onRegisterButtonPressed() async {
    setState(() {
      _isRegisterLoading = true;
    });
    try {
      final vm = Provider.of<LoginViewModel>(context, listen: false);
      final success = await vm.verifyRegisterCode();
      if (!mounted) return;
      setState(() {
        _isRegisterLoading = false;
      });
      if (success) {
        _showTopBanner('Account created successfully!',
            bgColor: Colors.green, icon: Icons.check_circle);
        _transitionToEmailStep();
      } else {
        _showTopBanner('Registration failed: ${vm.errorMessage ?? 'Please check your code and activation.'}',
            bgColor: Colors.red, icon: Icons.error_outline);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegisterLoading = false;
      });
      _showTopBanner('Registration failed: $e',
          bgColor: Colors.red, icon: Icons.error_outline);
    }
  }

  Widget _buildBottomInfo() {
    return CenteredBottomInfoPresets.brand();
  }

  // 轻触手感：Send Code按钮缩放
  double _sendCodeScale = 1.0;
  
  // 防抖动：防止重复点击发送验证码
  bool _isSendingCode = false;
  DateTime? _lastSendTime;
  static const Duration _sendCooldown = Duration(milliseconds: 500);

  Future<void> _onSendCodePressed() async {
    // 防抖动检查
    if (_isSendingCode) {
      print('🔄 防抖动：正在发送中，忽略重复点击');
      return;
    }
    
    // 冷却时间检查
    if (_lastSendTime != null) {
      final timeSinceLastSend = DateTime.now().difference(_lastSendTime!);
      if (timeSinceLastSend < _sendCooldown) {
        print('⏰ 防抖动：冷却时间内，忽略点击');
        return;
      }
    }
    
    if (!_isEmailValid) return;
    
    // 设置发送状态，防止重复点击
    setState(() { 
      _isSendingCode = true;
      _lastSendTime = DateTime.now();
    });
    
    try {
      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (_) {}
    
    // 按钮缩放动画
    if (mounted) setState(() { _sendCodeScale = 0.95; });
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) setState(() { _sendCodeScale = 1.0; });
    
    // 发送验证码
    await _sendVerificationCode();
    
    // 重置发送状态
    if (mounted) {
      setState(() { _isSendingCode = false; });
    }
  }

  /// 根据错误样式字符串获取颜色
  Color _getBannerColor(String colorType) {
    switch (colorType) {
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  /// 根据错误样式字符串获取图标
  IconData _getBannerIcon(String iconType) {
    switch (iconType) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'lock':
        return Icons.lock_outline;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.error_outline;
    }
  }
}

enum LoginStep {
  logo,
  options,      // 选项页面
  email,        // 登录表单
  activation,   // 激活码验证
  register,     // 注册表单
}


