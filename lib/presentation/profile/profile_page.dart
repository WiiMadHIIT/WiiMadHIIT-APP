import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../widgets/challenge_record_list_widget.dart';
import '../../widgets/checkin_record_list_widget.dart';
import '../../widgets/activate_product_sheet.dart';
import '../../widgets/code_reminder_sheet.dart';
import '../../widgets/equipment_activation_dialog.dart';
import '../../widgets/user_profile_edit_sheet.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/auth_guard_mixin.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/submit_activation_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/services/profile_service.dart';
import '../../data/repository/profile_repository.dart';
import '../../data/api/profile_api.dart';
import '../../routes/app_routes.dart';
import 'profile_viewmodel.dart';
import '../../widgets/checkin_refresh_helper.dart';
import '../../widgets/challenge_refresh_helper.dart';
import '../../widgets/account_settings_sheet.dart';
import '../../core/auth/auth_state_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ProfilePageContentState> _contentKey = GlobalKey<ProfilePageContentState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(
        getProfileUseCase: GetProfileUseCase(ProfileRepository(ProfileApi())),
        submitActivationUseCase: SubmitActivationUseCase(ProfileRepository(ProfileApi())),
        updateProfileUseCase: UpdateProfileUseCase(ProfileRepository(ProfileApi())),
        profileService: ProfileService(),
      )..loadProfile(),
      child: ProfilePageContent(key: _contentKey),
    );
  }

  /// 重置滑动提示状态
  void resetScrollHint() {
    _contentKey.currentState?.resetScrollHint();
  }

  /// 大厂级别：智能刷新Profile数据（代理方法）
  /// 有数据时不刷新，无数据时才刷新
  void smartRefreshProfileData() {
    _contentKey.currentState?.smartRefreshProfileData();
  }

  /// 清理分页数据（用于离开Profile tab时）
  void cleanupPaginatedData() {
    _contentKey.currentState?.cleanupPaginatedData();
  }
}

class ProfilePageContent extends StatefulWidget {
  const ProfilePageContent({Key? key}) : super(key: key);

  @override
  State<ProfilePageContent> createState() => ProfilePageContentState();
}

class ProfilePageContentState extends State<ProfilePageContent> 
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, AuthGuardMixin {
  late TabController _tabController;
  final GlobalKey<ProfileFunctionGridState> _functionGridKey = GlobalKey<ProfileFunctionGridState>();
  
  // 认证状态管理器
  late final AuthStateManager _authManager = AuthStateManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用从后台恢复时，重置滑动提示
    if (state == AppLifecycleState.resumed) {
      _functionGridKey.currentState?.resetScrollHint();
    }
  }

  /// 重置滑动提示状态
  void resetScrollHint() {
    _functionGridKey.currentState?.resetScrollHint();
  }

  /// 大厂级别：智能刷新Profile数据
  /// 有数据时不刷新，无数据时才刷新
  void smartRefreshProfileData() {
    try {
      // 通过 Provider 获取 ViewModel
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      
      // 检查是否有数据
      if (viewModel.profile == null) {
        // 无数据时，执行刷新
        print('🔐 ProfilePage: 无数据，执行刷新');
        viewModel.loadProfile();
      } else {
        // 有数据时，不刷新，只记录日志
        print('🔐 ProfilePage: 已有数据，跳过刷新');
      }
    } catch (e) {
      print('🔐 ProfilePage: 智能刷新失败: $e');
    }
  }

  /// 清理分页数据（用于离开Profile tab时）
  void cleanupPaginatedData() {
    try {
      // 通过 Provider 获取 ViewModel
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      
      // 调用 ViewModel 的清理方法
      viewModel.cleanupPaginatedData();
      print('🔐 ProfilePage: 分页数据清理完成');
    } catch (e) {
      print('🔐 ProfilePage: 分页数据清理失败: $e');
    }
  }

  /// 显示激活产品弹窗
  void _showActivateSheet(BuildContext context) {
    // 获取 ProfileViewModel
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    
    // 检查是否正在加载激活数据
    if (viewModel.isLoadingActivate) {
      // 显示"正在加载"提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.white),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Loading activation data...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Future<void> openSheet() async {
      // 显示激活弹窗
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: ActivateProductSheet(
            activateList: viewModel.activate,
            onActivate: (productId, activationCode) {
              // 处理激活逻辑
              print('Activating product: $productId with code: $activationCode');
              // 激活逻辑已经在 ActivateProductSheet 中处理
            },
          ),
        ),
      );
    }

    // 检查是否有激活数据
    if (!viewModel.hasActivateData) {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading activation data...',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we fetch the latest activation information',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      viewModel.loadActivate(page: 1, size: 10).then((success) {
        Navigator.of(context).pop();
        if (success && viewModel.hasActivateData) {
          openSheet();
        } else {
          // 显示错误提示，提供重试选项
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Failed to load activation data',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _showActivateSheet(context),
              ),
            ),
          );
        }
      });
      return;
    }

    openSheet();
  }

  /// 显示装备激活提示弹窗
  void _showEquipmentActivatedDialog(BuildContext context, String productName, String productId) {
    EquipmentActivationDialog.showEquipmentActivated(
      context,
      productName: productName,
      productId: productId,
    );
  }

  /// 显示挑战装备激活提示弹窗
  void _showChallengeEquipmentActivatedDialog(BuildContext context, String challengeName, String challengeId) {
    EquipmentActivationDialog.showChallengeEquipmentActivated(
      context,
      challengeName: challengeName,
      challengeId: challengeId,
    );
  }

  /// 显示挑战装备资格获得提示弹窗
  void _showChallengeEquipmentQualifiedDialog(BuildContext context, String challengeName, String challengeId) {
    EquipmentActivationDialog.showChallengeEquipmentQualified(
      context,
      challengeName: challengeName,
      challengeId: challengeId,
    );
  }

  /// 显示用户信息编辑弹窗
  void _showUserProfileEditSheet(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // 允许点击外部关闭
      enableDrag: true, // 允许拖拽关闭
      builder: (context) => UserProfileEditSheet(
        currentUsername: viewModel.username,
        currentEmail: viewModel.email ?? '',
        onSave: (username, email) async {
          // 调用 ViewModel 的更新方法
          print('Updating profile: username=$username, email=$email');
          
          // 直接使用外部获取的 viewModel 实例
          final success = await viewModel.updateProfile(
            username: username,
            email: email,
          );
          
          if (success) {
            // 更新成功，显示成功提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Profile updated successfully!',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else {
            // 更新失败，显示错误提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        viewModel.profileUpdateError ?? 'Failed to update profile',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          
          // 返回更新结果
          return success;
        },
        onCancel: () {
          // 弹窗关闭时的处理
          print('Profile edit cancelled');
          // 关闭弹窗
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// 构建挑战记录列表
  Widget _buildChallengeRecordList(ProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.hasError) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_esports, color: Colors.grey[400], size: 48),
              const SizedBox(height: 12),
              Text(
                'Challenge records are taking a coffee break ☕',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async { await loadChallengesWithDialog(context, viewModel, page: 1, size: 10); },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Refill'),
              ),
            ],
          ),
        ),
      );
    }

    if (!viewModel.hasData || viewModel.challengeRecords.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_esports, color: Colors.grey[400], size: 48),
              const SizedBox(height: 12),
              Text(
                'No past challenges yet 📜',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async { await loadChallengesWithDialog(context, viewModel, page: 1, size: 10); },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Rewind'),
              ),
            ],
          ),
        ),
      );
    }

    final records = viewModel.challengeRecordsForUI;
    
    return ChallengeRecordListWidget(
      records: records.toChallengeRecords(
        onTap: (record) {
          final status = record['status'] as String;
          final challengeId = record['challengeId'] as String?;
          final challengeName = record['name'] as String;
          
          if (status == 'ongoing' && challengeId != null) {
            // 显示挑战装备激活提示弹窗
            _showChallengeEquipmentActivatedDialog(context, challengeName, challengeId);
          } else if (status == 'ready' && challengeId != null) {
            // 显示挑战装备资格获得提示弹窗
            _showChallengeEquipmentQualifiedDialog(context, challengeName, challengeId);
          } else {
            // 其他状态的普通点击处理
            print('Clicked challenge record: ${record['name']} (ID: ${record['id']}, ChallengeID: ${record['challengeId']})');
          }
        },
      ),
      style: const ChallengeRecordListStyle(
        indexBackgroundColor: AppColors.primary,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        rankTextStyle: TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        timeTextStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        ongoingStatusColor: Color(0xFF00C851),
        ongoingBackgroundColor: Color(0xFFF0FFF4),
      ),
      hasMore: viewModel.hasMoreChallenges,
      onLoadMore: viewModel.loadMoreChallenges,
    );
  }

  /// 构建打卡记录列表
  Widget _buildCheckinRecordList(ProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.hasError) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, color: Colors.grey[400], size: 48),
              const SizedBox(height: 12),
              Text(
                'Check-in records are doing yoga 🧘‍♀️',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async { await loadCheckinsWithDialog(context, viewModel, page: 1, size: 10); },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Stretch'),
              ),
            ],
          ),
        ),
      );
    }

    if (!viewModel.hasData || viewModel.checkinRecords.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, color: Colors.grey[400], size: 48),
              const SizedBox(height: 12),
              Text(
                'Time to start your fitness adventure! 💪',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async { await loadCheckinsWithDialog(context, viewModel, page: 1, size: 10); },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Let's Go"),
              ),
            ],
          ),
        ),
      );
    }

    final records = viewModel.checkinRecordsForUI;
    
    return CheckinRecordListWidget(
      records: records.toCheckinRecords(
        onTap: (record) {
          final status = record['status'] as String;
          final productId = record['productId'] as String?;
          final productName = record['name'] as String;
          
          if (status == 'ready' && productId != null) {
            // 显示装备激活提示弹窗
            _showEquipmentActivatedDialog(context, productName, productId);
          } else {
            // 其他状态的普通点击处理
            print('Clicked checkin record: ${record['name']} (ID: ${record['id']}, ProductID: ${record['productId']})');
          }
        },
      ),
      style: const CheckinRecordListStyle(
        indexBackgroundColor: AppColors.primary,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        rankTextStyle: TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        timeTextStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
      ),
      hasMore: viewModel.hasMoreCheckins,
      onLoadMore: viewModel.loadMoreCheckins,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // 使用Consumer直接获取已创建的ProfileViewModel，避免重复创建
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () => viewModel.refreshProfile(),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 渐变遮罩
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.35),
                                Colors.transparent,
                                Colors.white.withOpacity(0.85),
                              ],
                              stops: const [0, 0.5, 1],
                            ),
                          ),
                        ),
                        // 右上角按钮组
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 16,
                          right: 20,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (viewModel.hasError) const SizedBox(width: 12),
                              _ActionButton(
                                icon: Icons.edit,
                                onTap: () => _showUserProfileEditSheet(context),
                              ),
                              const SizedBox(width: 12),
                              _ActionButton(
                                icon: Icons.settings,
                                onTap: () async {
                                  // 打开账户设置底部弹窗
                                  final authManager = AuthStateManager();
                                  await showAccountSettingsSheet(
                                    context,
                                    onLogout: () async {
                                      // 1. 清理当前页面的加载信息
                                      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
                                      viewModel.clearAllData();
                                      
                                      // 2. 退出登录
                                      await authManager.logout();
                                      
                                      if (mounted) {
                                        // 3. 显示退出成功提示
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Signed out successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        
                                        // 4. 跳转到首页tab页
                                        Navigator.of(context).pushReplacementNamed('/');
                                      }
                                    },
                                    onDelete: () async {
                                      if (!mounted) return;
                                      
                                      // 执行删除操作
                                      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
                                      final success = await viewModel.deleteAccount();
                                      
                                      if (success) {
                                        // 删除成功，显示成功提示
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(viewModel.accountDeletionSuccessMessage ?? 'Account deleted successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          
                                          // 延迟后执行完整的退出登录流程
                                          Future.delayed(const Duration(seconds: 2), () async {
                                            if (mounted) {
                                              // 1. 清理当前页面的加载信息
                                              viewModel.clearAllData();
                                              
                                              // 2. 退出登录
                                              await authManager.logout();
                                              
                                              if (mounted) {
                                                // 3. 显示删除成功并退出登录的提示
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Account deleted and signed out successfully'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                                
                                                // 4. 跳转到登录页面
                                                Navigator.of(context).pushReplacementNamed('/');
                                              }
                                            }
                                          });
                                        }
                                      } else {
                                        // 删除失败，显示错误提示
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(viewModel.accountDeletionError ?? 'Failed to delete account'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // 头像+用户名+运动天数
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 90,
                          child: viewModel.isLoading 
                            ? const Column(
                                children: [
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.white,
                                    child: CircularProgressIndicator(),
                                  ),
                                  SizedBox(height: 12),
                                  Text('Loading...',
                                    style: TextStyle(
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  // 用户头像
                                  _SmartAvatar(
                                    radius: 48,
                                    avatarUrl: viewModel.avatarUrl,
                                    fallbackImage: 'assets/images/avatar_default.png',
                                  ),
                                  const SizedBox(height: 12),
                                  // 用户昵称
                                  Text(viewModel.username,
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  // 用户ID
                                  Text('User ID: ${viewModel.userId}',
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  // 运动天数统计
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _StatBlock(label: 'Current Streak', value: viewModel.currentStreakText),
                                      const SizedBox(width: 18),
                                      _StatBlock(label: 'Days This Year', value: viewModel.daysThisYearText),
                                    ],
                                  ),
                                ],
                              ),
                        ),
                        // 荣誉墙
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _HonorWall(viewModel: viewModel),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 6)),
                SliverToBoxAdapter(child: _ProfileFunctionGrid(
                  key: _functionGridKey,
                  onActivateTap: () => _showActivateSheet(context),
                )),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey[500],
                      labelStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: AppTextStyles.titleMedium,
                      tabs: const [
                        Tab(text: 'Check-ins'),
                        Tab(text: 'Challenges'),
                      ],
                    ),
                  ),
                ),
              ],
              body: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: TabBarView(   
                  controller: _tabController,
                  children: [
                    _buildCheckinRecordList(viewModel),
                    _buildChallengeRecordList(viewModel),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value, 
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label, 
          style: AppTextStyles.labelMedium.copyWith(color: Colors.grey[700]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HonorWall extends StatelessWidget {
  final ProfileViewModel viewModel;

  const _HonorWall({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _buildHonorContent(),
      ),
    );
  }

  Widget _buildHonorContent() {
    if (viewModel.isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.hasError) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.grey[400], size: 24),
              const SizedBox(height: 4),
              Text(
                'Honors are on vacation 🏖️',
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!viewModel.hasData || viewModel.honors.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.grey[400], size: 24),
              const SizedBox(height: 4),
              Text(
                'Your trophy collection awaits! 🏅',
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 显示前两个荣誉
    final honors = viewModel.honors.take(2).toList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: honors.map((honor) => Expanded(
        child: _MedalWidget(
          icon: honor.icon,
          label: honor.label,
          desc: honor.description,
        ),
      )).toList(),
    );
  }
}

class _MedalWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  const _MedalWidget({required this.icon, required this.label, required this.desc});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            label, 
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary, 
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Flexible(
          child: Text(
            desc, 
            style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}

class _ProfileFunctionGrid extends StatefulWidget {
  final VoidCallback? onActivateTap;
  
  const _ProfileFunctionGrid({
    Key? key,
    this.onActivateTap,
  }) : super(key: key);
  
  @override
  State<_ProfileFunctionGrid> createState() => ProfileFunctionGridState();
}

class ProfileFunctionGridState extends State<_ProfileFunctionGrid> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showScrollHint = true;
  bool _hasScrolled = false;
  bool _needsScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_hasScrolled) {
        // 使用 SchedulerBinding.addPostFrameCallback 避免在滚动过程中直接调用 setState
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasScrolled = true;
              _showScrollHint = false;
            });
          }
        });
        _animationController.stop();
      }
    });

    _startScrollHint();
  }

  void _startScrollHint() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _showScrollHint) {
        // 使用 SchedulerBinding.addPostFrameCallback 确保在正确的时机启动动画
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && _showScrollHint) {
            _animationController.repeat(reverse: true);
          }
        });
      }
    });
  }

  void resetScrollHint() {
    // 使用 SchedulerBinding.addPostFrameCallback 避免在回调中直接调用 setState
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _showScrollHint = true;
          _hasScrolled = false;
        });
      }
    });
    _animationController.stop();
    _startScrollHint();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.card_giftcard, 
        'label': 'Activate',
        'onTap': widget.onActivateTap,
      },
      {
        'icon': Icons.help_outline, 
        'label': 'Reminder',
        'onTap': () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const CodeReminderSheet(),
          );
        },
      },
    ];
    
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = 60.0;
                final itemSpacing = 6.0;
                final totalContentWidth = (items.length * itemWidth) + 
                    ((items.length - 1) * itemSpacing) + 16;
                
                // 使用 SchedulerBinding.addPostFrameCallback 避免在 build 阶段调用 setState
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _needsScrolling != (totalContentWidth > constraints.maxWidth)) {
                    setState(() {
                      _needsScrolling = totalContentWidth > constraints.maxWidth;
                    });
                  }
                });
                
                if (totalContentWidth <= constraints.maxWidth) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: SizedBox(
                          width: itemWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 40,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: item['onTap'] as VoidCallback?,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.10),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(item['icon'] as IconData, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 32,
                                child: Center(
                                  child: Text(
                                    item['label'] as String,
                                    style: AppTextStyles.labelMedium.copyWith(color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: itemWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: item['onTap'] as VoidCallback?,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(item['icon'] as IconData, color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 32,
                                    child: Center(
                                      child: Text(
                                        item['label'] as String,
                                        style: AppTextStyles.labelMedium.copyWith(color: Colors.black87),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          
          if (_showScrollHint && !_hasScrolled && _needsScrolling)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_left,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Swipe',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 智能头像组件 - 自动处理网络图片加载失败，回退到默认头像
class _SmartAvatar extends StatefulWidget {
  final double radius;
  final String avatarUrl;
  final String fallbackImage;

  const _SmartAvatar({
    required this.radius,
    required this.avatarUrl,
    required this.fallbackImage,
  });

  @override
  State<_SmartAvatar> createState() => _SmartAvatarState();
}

class _SmartAvatarState extends State<_SmartAvatar> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(_SmartAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      _isLoading = true;
      _hasError = false;
      _loadAvatar();
    }
  }

  void _loadAvatar() {
    if (widget.avatarUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    // 检查URL类型并处理
    String processedUrl = _processAvatarUrl(widget.avatarUrl);
    
    if (processedUrl.startsWith('http')) {
      // 预加载网络图片，处理成功和失败情况
      NetworkImage(processedUrl)
          .resolve(ImageConfiguration.empty)
          .addListener(
            ImageStreamListener(
              (info, _) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasError = false;
                  });
                }
              },
              onError: (exception, stackTrace) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                  });
                  print('🔐 _SmartAvatar: 网络图片加载失败: $exception');
                }
              },
            ),
          );
    } else {
      // 本地资源，直接设置为加载完成
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    }
  }

  /// 处理头像URL，确保http转换为https，非http URL使用默认头像
  String _processAvatarUrl(String url) {
    if (url.isEmpty) {
      return widget.fallbackImage;
    }
    
    // 如果是http开头，转换为https
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    
    // 如果已经是https开头，直接返回
    if (url.startsWith('https://')) {
      return url;
    }
    
    // 如果不是http/https开头，使用默认头像
    return widget.fallbackImage;
  }

  @override
  Widget build(BuildContext context) {
    String processedUrl = _processAvatarUrl(widget.avatarUrl);
    
    // 如果URL为空、不是HTTP URL、或者加载失败，使用默认头像
    if (widget.avatarUrl.isEmpty || !processedUrl.startsWith('http') || _hasError) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(widget.fallbackImage),
      );
    }

    if (_isLoading) {
      // 显示加载状态
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    // 显示网络头像
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.white,
      backgroundImage: NetworkImage(processedUrl),
    );
  }
}
