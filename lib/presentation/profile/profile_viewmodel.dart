import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/submit_activation_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/activation_request.dart';
import '../../domain/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final SubmitActivationUseCase submitActivationUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ProfileService profileService;

  Profile? profile;
  String? error;
  bool isLoading = false;
  

  
  // 新增：激活码提交相关状态
  bool isSubmittingActivation = false;
  String? activationError;
  String? activationSuccessMessage;

  // 新增：用户信息更新相关状态
  bool isUpdatingProfile = false;
  String? profileUpdateError;
  String? profileUpdateSuccessMessage;

  // 新增：账号删除相关状态
  bool isDeletingAccount = false;
  String? accountDeletionError;
  String? accountDeletionSuccessMessage;

  // 新增：激活分页加载状态
  bool isLoadingActivate = false;
  int activateTotal = 0;
  int activateCurrentPage = 1;
  int activatePageSize = 10;

  // 新增：打卡加载状态
  bool isLoadingCheckins = false;
  int checkinTotal = 0;
  int checkinCurrentPage = 1;
  int checkinPageSize = 10;
  bool hasMoreCheckins = true;

  // 新增：挑战加载状态
  bool isLoadingChallenges = false;
  int challengeTotal = 0;
  int challengeCurrentPage = 1;
  int challengePageSize = 10;
  bool hasMoreChallenges = true;

  // 新增：时间戳跟踪（用于基于时间的刷新）
  DateTime? _lastFullRefreshTime;
  static const Duration _refreshInterval = Duration(hours: 24);

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.submitActivationUseCase,
    required this.updateProfileUseCase,
    required this.profileService,
  });

  Future<void> loadProfile() async {
    print('🔍 ProfileViewModel: 开始加载Profile数据');
    
    // 检查是否已经在加载中
    if (isLoading) {
      print('🔍 ProfileViewModel: 已在加载中，跳过重复请求');
      return;
    }
    
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      print('🔍 ProfileViewModel: 调用UseCase执行数据加载');
      profile = await getProfileUseCase.execute(existingProfile: profile);
      error = null; // 确保成功时清除错误
      print('🔍 ProfileViewModel: Profile数据加载成功');
    } catch (e) {
      error = e.toString();
      profile = null;
      print('🔍 ProfileViewModel: Profile数据加载失败: $e');
    } finally {
      isLoading = false;
      notifyListeners();
      print('🔍 ProfileViewModel: Profile数据加载完成，状态: ${isLoading ? 'loading' : 'loaded'}');
    }
  }

  /// 强制刷新Profile数据（用于认证成功后）
  Future<void> forceRefreshProfile() async {
    print('🔍 ProfileViewModel: 强制刷新Profile数据');
    
    // 强制刷新时，先重置所有状态
    isLoading = false;
    error = null;
    profile = null;
    
    // 重新加载
    await loadProfile();
  }

  // 新增：仅加载激活分页数据，并合并进现有 Profile
  Future<bool> loadActivate({int page = 1, int size = 10}) async {
    if (isLoadingActivate) return false;
    
    // 检查 profile 是否存在，如果不存在则不执行
    if (profile == null) {
      print('🔍 ProfileViewModel: Profile 未加载，跳过激活数据加载');
      return false;
    }
    
    isLoadingActivate = true;
    notifyListeners();

    try {
      final pageResult = await getProfileUseCase.executeFetchActivate(page: page, size: size);
      activateTotal = pageResult.total;
      activateCurrentPage = pageResult.currentPage;
      activatePageSize = pageResult.pageSize;

      // 合并数据到现有 Profile
      profile = profileService.mergeActivateIntoProfile(profile!, pageResult);

      // 确保状态更新后立即通知监听器
      isLoadingActivate = false;
      notifyListeners();
      
      print('🔍 ProfileViewModel: 激活数据加载成功，共 ${pageResult.activate.length} 条记录');
      print('🔍 ProfileViewModel: hasActivateData = ${hasActivateData}');
      
      return true;
    } catch (e) {
      error = e.toString();
      print('🔍 ProfileViewModel: 激活数据加载失败: $e');
      isLoadingActivate = false;
      notifyListeners();
      return false;
    }
  }

  // 新增：加载打卡数据（支持下滑加载）
  Future<bool> loadCheckins({int page = 1, int size = 10}) async {
    if (isLoadingCheckins) return false;
    
    // 检查 profile 是否存在，如果不存在则不执行
    if (profile == null) {
      print('🔍 ProfileViewModel: Profile 未加载，跳过打卡数据加载');
      return false;
    }
    
    isLoadingCheckins = true;
    notifyListeners();

    try {
      final pageResult = await getProfileUseCase.executeFetchCheckins(page: page, size: size);
      checkinTotal = pageResult.total;
      checkinCurrentPage = pageResult.currentPage;
      checkinPageSize = pageResult.pageSize;

      if (page == 1) {
        // 第一页：替换数据
        profile = profileService.mergeCheckinsIntoProfile(profile!, pageResult);
      } else {
        // 后续页：追加数据
        final existingRecords = profile!.checkinRecords;
        final combinedRecords = [...existingRecords, ...pageResult.checkinRecords];
        
        // 创建新的分页结果，包含合并的记录
        final combinedPageResult = CheckinPage(
          checkinRecords: combinedRecords,
          total: pageResult.total,
          currentPage: pageResult.currentPage,
          pageSize: pageResult.pageSize,
        );
        
        profile = profileService.mergeCheckinsIntoProfile(profile!, combinedPageResult);
      }

      // 检查是否还有更多数据
      hasMoreCheckins = checkinRecords.length < checkinTotal;

      isLoadingCheckins = false;
      notifyListeners();

      print('🔍 ProfileViewModel: 打卡数据加载成功，共 ${pageResult.checkinRecords.length} 条记录');
      print('🔍 ProfileViewModel: 总记录数: $checkinTotal, 当前记录数: ${checkinRecords.length}, 还有更多: $hasMoreCheckins');
      return true;
    } catch (e) {
      error = e.toString();
      print('🔍 ProfileViewModel: 打卡数据加载失败: $e');
      isLoadingCheckins = false;
      notifyListeners();
      return false;
    }
  }

  // 新增：加载更多打卡数据
  Future<bool> loadMoreCheckins() async {
    if (isLoadingCheckins || !hasMoreCheckins) return false;
    final nextPage = checkinCurrentPage + 1;
    print('🔍 ProfileViewModel: 加载更多打卡数据，页码: $nextPage');
    return await loadCheckins(page: nextPage, size: checkinPageSize);
  }

  // 新增：加载挑战数据（支持下滑加载）
  Future<bool> loadChallenges({int page = 1, int size = 10}) async {
    if (isLoadingChallenges) return false;
    
    // 检查 profile 是否存在，如果不存在则不执行
    if (profile == null) {
      print('🔍 ProfileViewModel: Profile 未加载，跳过挑战数据加载');
      return false;
    }
    
    isLoadingChallenges = true;
    notifyListeners();

    try {
      final pageResult = await getProfileUseCase.executeFetchChallenges(page: page, size: size);
      challengeTotal = pageResult.total;
      challengeCurrentPage = pageResult.currentPage;
      challengePageSize = pageResult.pageSize;

      if (page == 1) {
        // 第一页：替换数据
        profile = profileService.mergeChallengesIntoProfile(profile!, pageResult);
      } else {
        // 后续页：追加数据
        final existingRecords = profile!.challengeRecords;
        final combinedRecords = [...existingRecords, ...pageResult.challengeRecords];
        
        // 创建新的分页结果，包含合并的记录
        final combinedPageResult = ChallengePage(
          challengeRecords: combinedRecords,
          total: pageResult.total,
          currentPage: pageResult.currentPage,
          pageSize: pageResult.pageSize,
        );
        
        profile = profileService.mergeChallengesIntoProfile(profile!, combinedPageResult);
      }

      // 检查是否还有更多数据
      hasMoreChallenges = challengeRecords.length < challengeTotal;

      isLoadingChallenges = false;
      notifyListeners();

      print('🔍 ProfileViewModel: 挑战数据加载成功，共 ${pageResult.challengeRecords.length} 条记录');
      print('🔍 ProfileViewModel: 总记录数: $challengeTotal, 当前记录数: ${challengeRecords.length}, 还有更多: $hasMoreChallenges');
      return true;
    } catch (e) {
      error = e.toString();
      print('🔍 ProfileViewModel: 挑战数据加载失败: $e');
      isLoadingChallenges = false;
      notifyListeners();
      return false;
    }
  }

  // 新增：加载更多挑战数据
  Future<bool> loadMoreChallenges() async {
    if (isLoadingChallenges || !hasMoreChallenges) return false;
    
    final nextPage = challengeCurrentPage + 1;
    print('🔍 ProfileViewModel: 加载更多挑战数据，页码: $nextPage');
    
    return await loadChallenges(page: nextPage, size: challengePageSize);
  }

  Future<void> refreshProfile() async {
    print('🔍 ProfileViewModel: 开始刷新Profile数据');
    
    // 强制刷新时，先重置loading状态，然后重新加载
    isLoading = false;
    error = null;
    
    // 重新加载基础Profile数据
    await loadProfile();
    
    // 如果Profile加载成功，同时刷新打卡和挑战数据
    if (profile != null) {
      print('🔍 ProfileViewModel: Profile数据加载成功，开始刷新打卡和挑战数据');
      
      // 并行刷新打卡和挑战数据（第一页）
      await Future.wait([
        loadCheckins(page: 1, size: checkinPageSize),
        loadChallenges(page: 1, size: challengePageSize),
      ]);
      
      print('🔍 ProfileViewModel: 打卡和挑战数据刷新完成');
    } else {
      print('🔍 ProfileViewModel: Profile数据加载失败，跳过打卡和挑战数据刷新');
    }
  }

  /// 专门用于Check-ins列表的下拉刷新
  Future<void> refreshCheckins() async {
    print('🔍 ProfileViewModel: 开始刷新Check-ins数据');
    
    // 先确保Profile数据存在
    if (profile == null) {
      print('🔍 ProfileViewModel: Profile数据不存在，先加载Profile');
      await loadProfile();
    }
    
    // 如果Profile加载成功，只刷新打卡数据
    if (profile != null) {
      print('🔍 ProfileViewModel: 开始刷新打卡数据');
      await loadCheckins(page: 1, size: checkinPageSize);
      print('🔍 ProfileViewModel: 打卡数据刷新完成');
    } else {
      print('🔍 ProfileViewModel: Profile数据加载失败，跳过打卡数据刷新');
    }
  }

  /// 专门用于Challenges列表的下拉刷新
  Future<void> refreshChallenges() async {
    print('🔍 ProfileViewModel: 开始刷新Challenges数据');
    
    // 先确保Profile数据存在
    if (profile == null) {
      print('🔍 ProfileViewModel: Profile数据不存在，先加载Profile');
      await loadProfile();
    }
    
    // 如果Profile加载成功，只刷新挑战数据
    if (profile != null) {
      print('🔍 ProfileViewModel: 开始刷新挑战数据');
      await loadChallenges(page: 1, size: challengePageSize);
      print('🔍 ProfileViewModel: 挑战数据刷新完成');
    } else {
      print('🔍 ProfileViewModel: Profile数据加载失败，跳过挑战数据刷新');
    }
  }

  /// 智能刷新：结合时间检查和数据存在性检查
  /// 如果距离上次完整刷新超过24小时，执行完整刷新
  /// 否则执行智能刷新（有数据时跳过）
  Future<void> smartRefreshWithTimeCheck() async {
    print('🔍 ProfileViewModel: 开始智能时间检查刷新');
    
    final now = DateTime.now();
    final shouldFullRefresh = _lastFullRefreshTime == null || 
        now.difference(_lastFullRefreshTime!) >= _refreshInterval;
    
    if (shouldFullRefresh) {
      print('🔍 ProfileViewModel: 距离上次完整刷新超过24小时，执行完整刷新');
      await refreshProfile();
      _lastFullRefreshTime = now;
      print('🔍 ProfileViewModel: 完整刷新完成，更新时间戳: $_lastFullRefreshTime');
    } else {
      print('🔍 ProfileViewModel: 距离上次完整刷新未超过24小时，执行智能刷新');
      await smartRefreshProfile();
    }
  }

  /// 智能刷新Profile数据（有数据时不刷新，无数据时才刷新）
  Future<void> smartRefreshProfile() async {
    print('🔍 ProfileViewModel: 开始智能刷新Profile数据');
    
    // 检查是否有数据
    if (profile == null) {
      // 无数据时，执行刷新
      print('🔍 ProfileViewModel: 无数据，执行刷新');
      await loadProfile();
    } else {
      // 有数据时，不刷新，只记录日志
      print('🔍 ProfileViewModel: 已有数据，跳过刷新');
    }
  }

  // 计算属性
  bool get hasData => profile != null;
  bool get hasError => error != null;
  bool get isDataComplete => profile != null && profileService.isProfileComplete(profile!);

  // 用户相关
  User? get user => profile?.user;
  String get username => user?.username ?? 'Guest User';
  String get userId => user?.userId ?? 'Not Available';
  String get email => user?.email ?? '';
  String get avatarUrl => user?.avatarUrl ?? 'assets/images/avatar_default.png';
  bool get hasAvatar => user?.hasAvatar ?? false;

  // 统计数据相关
  UserStats? get stats => profile?.stats;
  int get currentStreak => stats?.currentStreak ?? 0;
  int get daysThisYear => stats?.daysThisYear ?? 0;
  int get daysAllTime => stats?.daysAllTime ?? 0;
  String get currentStreakText => stats?.currentStreakText ?? '0 days';
  String get daysThisYearText => stats?.daysThisYearText ?? '0 days';
  String get daysAllTimeText => stats?.daysAllTimeText ?? '0 days';
  int get level => stats?.level ?? 1;
  String get levelName => stats?.levelName ?? 'Newcomer';
  double get nextLevelProgress => stats?.nextLevelProgress ?? 0.0;

  // 荣誉相关
  List<Honor> get honors => profile?.honors ?? [];
  List<Honor> get sortedHonors => profile?.sortedHonors ?? [];
  List<Honor> get highPriorityHonors => 
    profile != null ? profileService.getHighPriorityHonors(profile!) : [];
  List<Honor> get thisWeekHonors => 
    profile != null ? profileService.getThisWeekHonors(profile!) : [];
  List<Honor> get thisMonthHonors => 
    profile != null ? profileService.getThisMonthHonors(profile!) : [];

  // 挑战记录相关
  List<ChallengeRecord> get challengeRecords => profile?.challengeRecords ?? [];
  List<ChallengeRecord> get sortedChallengeRecords => profile?.sortedChallengeRecords ?? [];
  List<ChallengeRecord> get ongoingChallenges => profile?.ongoingChallenges ?? [];
  List<ChallengeRecord> get completedChallenges => profile?.completedChallenges ?? [];
  List<ChallengeRecord> get readyChallenges => profile?.readyChallenges ?? [];
  List<ChallengeRecord> get recentCompletedChallenges => 
    profile != null ? profileService.getRecentCompletedChallenges(profile!) : [];
  List<ChallengeRecord> get upcomingChallenges => 
    profile != null ? profileService.getUpcomingChallenges(profile!) : [];

  // 打卡记录相关
  List<CheckinRecord> get checkinRecords => profile?.checkinRecords ?? [];
  List<CheckinRecord> get sortedCheckinRecords => profile?.sortedCheckinRecords ?? [];
  List<CheckinRecord> get ongoingCheckins => profile?.ongoingCheckins ?? [];
  List<CheckinRecord> get completedCheckins => profile?.completedCheckins ?? [];
  List<CheckinRecord> get readyCheckins => profile?.readyCheckins ?? [];
  List<CheckinRecord> get recentCompletedCheckins => 
    profile != null ? profileService.getRecentCompletedCheckins(profile!) : [];
  List<CheckinRecord> get upcomingCheckins => 
    profile != null ? profileService.getUpcomingCheckins(profile!) : [];

  // 激活关联相关
  List<Activate> get activate => profile?.activate ?? [];

  // 新增：检查是否有激活数据的计算属性
  bool get hasActivateData => activate.isNotEmpty;

  // 统计摘要
  Map<String, dynamic> get profileSummary => 
    profile != null ? profileService.getProfileSummary(profile!) : {};

  // 成就相关
  double get achievementScore => profileSummary['achievementScore'] ?? 0.0;
  List<String> get newAchievements => 
    profile != null ? profileService.checkNewAchievements(profile!) : [];

  // 新增：激活关联统计
  int get totalActivations => profileSummary['totalActivations'] ?? 0;
  int get associatedChallenges => profileSummary['associatedChallenges'] ?? 0;
  int get associatedCheckins => profileSummary['associatedCheckins'] ?? 0;

  // 数据验证
  bool get isChallengeRecordsValid => 
    profile != null ? profileService.validateChallengeRecords(challengeRecords) : false;
  bool get isCheckinRecordsValid => 
    profile != null ? profileService.validateCheckinRecords(checkinRecords) : false;
  bool get isHonorsValid => 
    profile != null ? profileService.validateHonors(honors) : false;

  // 错误处理
  void clearError() {
    error = null;
    notifyListeners();
  }

  // 获取挑战记录用于 UI 显示
  List<Map<String, dynamic>> get challengeRecordsForUI {
    return sortedChallengeRecords.map((record) => {
      'id': record.id,
      'challengeId': record.challengeId,
      'index': record.index,
      'name': record.name,
      'rank': record.rank,
      'status': record.status,
      'timestep': record.timestep,
    }).toList();
  }

  // 获取打卡记录用于 UI 显示
  List<Map<String, dynamic>> get checkinRecordsForUI {
    return sortedCheckinRecords.map((record) => {
      'id': record.id,
      'productId': record.productId,
      'index': record.index,
      'name': record.name,
      'status': record.status,
      'timestep': record.timestep,
      'rank': record.rank,
    }).toList();
  }

  // 获取荣誉用于 UI 显示
  List<Map<String, dynamic>> get honorsForUI {
    return sortedHonors.map((honor) => {
      'icon': honor.icon,
      'label': honor.label,
      'description': honor.description,
      'timestep': honor.timestep,
    }).toList();
  }

  // 新增：激活码提交相关方法

  /// 提交激活码
  Future<bool> submitActivationCode(String productId, String activationCode) async {
    print('🔍 ProfileViewModel: 开始提交激活码');
    print('🔍 ProfileViewModel: 产品ID: $productId');
    
    if (isSubmittingActivation) {
      print('🔍 ProfileViewModel: 正在提交中，忽略重复请求');
      return false;
    }

    setState(() {
      isSubmittingActivation = true;
      activationError = null;
      activationSuccessMessage = null;
    });

    try {
      print('🔍 ProfileViewModel: 调用UseCase执行激活码提交');
      final result = await submitActivationUseCase.execute(productId, activationCode);
      
      print('🔍 ProfileViewModel: UseCase返回结果: $result');
      
      if (result) {
        // 激活成功
        print('🔍 ProfileViewModel: 激活成功，设置成功消息');
        activationSuccessMessage = profileService.getActivationStatusMessage(true);
        profileService.handleActivationSuccess(profile!, productId);
        
        // 激活成功后，可以刷新 profile 数据以获取最新的激活状态
        // 这样用户就能看到审核状态的变化
        // await loadProfile();
      } else {
        // 激活失败
        print('🔍 ProfileViewModel: 激活失败，设置错误消息');
        activationError = profileService.getActivationStatusMessage(false);
        profileService.handleActivationFailure(productId, 'Unable to submit activation code');
      }
      
      return result;
    } catch (e) {
      print('🔍 ProfileViewModel: 激活码提交异常: $e');
      activationError = 'Submission failed: ${e.toString()}';
      profileService.handleActivationFailure(productId, e.toString());
      return false;
    } finally {
      setState(() {
        isSubmittingActivation = false;
      });
      print('🔍 ProfileViewModel: 激活码提交完成');
    }
  }

  /// 提交激活码（使用 ActivationRequest 实体）
  Future<bool> submitActivationRequest(ActivationRequest request) async {
    return submitActivationCode(request.productId, request.activationCode);
  }

  /// 清除激活码相关状态
  void clearActivationState() {
    activationError = null;
    activationSuccessMessage = null;
    notifyListeners();
  }

  /// 清除用户信息更新相关状态
  void clearProfileUpdateState() {
    profileUpdateError = null;
    profileUpdateSuccessMessage = null;
    notifyListeners();
  }

  /// 检查产品是否可以激活
  bool canActivateProduct(String productId) {
    return profile != null ? profileService.canActivateProduct(profile!, productId) : false;
  }

  /// 获取可激活的产品列表
  List<Activate> get availableProducts {
    return profile != null ? profileService.getAvailableProducts(profile!) : [];
  }

  /// 获取激活关联信息
  Map<String, dynamic> getActivationInfo(String productId) {
    return profile != null ? profileService.getActivationInfo(profile!, productId) : {};
  }

  /// 根据挑战ID获取挑战记录
  ChallengeRecord? getChallengeRecordById(String challengeId) {
    return profile != null ? profileService.getChallengeRecordById(profile!, challengeId) : null;
  }

  /// 根据产品ID获取打卡记录
  CheckinRecord? getCheckinRecordByProductId(String productId) {
    return profile != null ? profileService.getCheckinRecordByProductId(profile!, productId) : null;
  }

  /// 获取挑战与产品的关联状态
  Map<String, dynamic> getChallengeProductAssociation(String challengeId) {
    return profile != null ? profileService.getChallengeProductAssociation(profile!, challengeId) : {};
  }

  /// 验证激活码格式
  bool validateActivationCode(String activationCode) {
    return profileService.validateActivationCode(activationCode);
  }

  // 新增：用户信息更新相关方法

  /// 更新用户信息
  Future<bool> updateProfile({
    String? username,
    String? email,
  }) async {
    print('🔍 ProfileViewModel: 开始更新用户信息');
    print('🔍 ProfileViewModel: 用户名: $username, 邮箱: $email');
    
    if (isUpdatingProfile) {
      print('🔍 ProfileViewModel: 正在更新中，忽略重复请求');
      return false;
    }

          // 验证输入
      if (!profileService.validateProfileUpdate(username: username, email: email)) {
        print('🔍 ProfileViewModel: 输入验证失败');
        profileUpdateError = 'Please check your input and try again';
        notifyListeners();
        return false;
      }

    setState(() {
      isUpdatingProfile = true;
      profileUpdateError = null;
      profileUpdateSuccessMessage = null;
    });

    try {
      print('🔍 ProfileViewModel: 调用UseCase执行用户信息更新');
      final result = await updateProfileUseCase.execute(
        username: username,
        email: email,
      );
      
      print('🔍 ProfileViewModel: UseCase返回结果: $result');
      
      if (result) {
        // 更新成功
        print('🔍 ProfileViewModel: 用户信息更新成功');
        profileUpdateSuccessMessage = profileService.getProfileUpdateStatusMessage(true);
        
        // 更新本地数据
        _updateLocalProfile(username: username, email: email);
        
        // 处理成功逻辑
        profileService.handleProfileUpdateSuccess(profile!, username: username, email: email);
      } else {
        // 更新失败
        print('🔍 ProfileViewModel: 用户信息更新失败');
        profileUpdateError = profileService.getProfileUpdateStatusMessage(false);
        profileService.handleProfileUpdateFailure(
          username: username, 
          email: email, 
          errors: {'general': 'Unable to update profile'}
        );
      }
      
      return result;
    } catch (e) {
      print('🔍 ProfileViewModel: 用户信息更新异常: $e');
      profileUpdateError = 'Update failed: ${e.toString()}';
      profileService.handleProfileUpdateFailure(
        username: username, 
        email: email, 
        errors: {'general': 'An error occurred while updating'}
      );
      return false;
    } finally {
      setState(() {
        isUpdatingProfile = false;
      });
      print('🔍 ProfileViewModel: 用户信息更新完成');
    }
  }

  /// 更新本地用户信息
  void _updateLocalProfile({
    String? username,
    String? email,
  }) {
    if (profile != null) {
      final updatedUser = profile!.user.copyWith(
        username: username,
        email: email,
      );
      
      profile = profile!.copyWith(user: updatedUser);
      print('🔍 ProfileViewModel: 本地用户信息已更新');
      print('🔍 ProfileViewModel: 新用户名: ${updatedUser.username}');
      print('🔍 ProfileViewModel: 新邮箱: ${updatedUser.email}');
    }
  }

  /// 验证用户信息更新
  bool validateProfileUpdate({
    String? username,
    String? email,
  }) {
    return profileService.validateProfileUpdate(
      username: username,
      email: email,
    );
  }

  // 新增：账号删除相关方法

  /// 删除用户账号
  Future<bool> deleteAccount() async {
    print('🔍 ProfileViewModel: 开始删除用户账号');
    
    if (isDeletingAccount) {
      print('🔍 ProfileViewModel: 正在删除中，忽略重复请求');
      return false;
    }

    // 验证是否可以删除账号
    if (profile != null && !profileService.validateAccountDeletion(profile!)) {
      print('🔍 ProfileViewModel: 账号删除验证失败，有进行中的活动');
      accountDeletionError = 'Cannot delete account while you have ongoing challenges or check-ins. Please complete them first.';
      notifyListeners();
      return false;
    }

    setState(() {
      isDeletingAccount = true;
      accountDeletionError = null;
      accountDeletionSuccessMessage = null;
    });

    try {
      print('🔍 ProfileViewModel: 调用UseCase执行账号删除');
      final result = await getProfileUseCase.executeDeleteAccount();
      
      print('🔍 ProfileViewModel: UseCase返回结果: $result');
      
      if (result) {
        // 删除成功
        print('🔍 ProfileViewModel: 账号删除成功');
        accountDeletionSuccessMessage = profileService.getAccountDeletionStatusMessage(true);
        
        // 清理本地数据
        _clearLocalData();
        
        // 处理成功逻辑
        profileService.handleAccountDeletionSuccess();
      } else {
        // 删除失败
        print('🔍 ProfileViewModel: 账号删除失败');
        accountDeletionError = profileService.getAccountDeletionStatusMessage(false);
        profileService.handleAccountDeletionFailure('Unable to delete account');
      }
      
      return result;
    } catch (e) {
      print('🔍 ProfileViewModel: 账号删除异常: $e');
      accountDeletionError = 'Deletion failed: ${e.toString()}';
      profileService.handleAccountDeletionFailure(e.toString());
      return false;
    } finally {
      setState(() {
        isDeletingAccount = false;
      });
      print('🔍 ProfileViewModel: 账号删除完成');
    }
  }

  /// 清理本地数据
  void _clearLocalData() {
    // 清理用户资料
    profile = null;
    
    // 清理错误状态
    error = null;
    
    // 清理激活相关状态
    activationError = null;
    activationSuccessMessage = null;
    
    // 清理用户信息更新相关状态
    profileUpdateError = null;
    profileUpdateSuccessMessage = null;
    
    // 清理分页状态
    activateTotal = 0;
    activateCurrentPage = 1;
    checkinTotal = 0;
    checkinCurrentPage = 1;
    challengeTotal = 0;
    challengeCurrentPage = 1;
    
    print('🔍 ProfileViewModel: 本地数据已清理');
  }

  /// 清除账号删除相关状态
  void clearAccountDeletionState() {
    accountDeletionError = null;
    accountDeletionSuccessMessage = null;
    notifyListeners();
  }

  /// 清理分页数据（用于离开Profile tab时）
  void cleanupPaginatedData() {
    print('🔍 ProfileViewModel: 开始清理分页数据');
    
    if (profile == null) {
      print('🔍 ProfileViewModel: Profile为空，无需清理分页数据');
      return;
    }
    
    // 清理打卡数据：保留第一页，清理后续页
    if (checkinRecords.length > checkinPageSize) {
      final firstPageRecords = checkinRecords.take(checkinPageSize).toList();
      profile = profile!.copyWith(checkinRecords: firstPageRecords);
      print('🔍 ProfileViewModel: 打卡数据已清理，保留 ${firstPageRecords.length} 条记录');
    }
    
    // 清理挑战数据：保留第一页，清理后续页
    if (challengeRecords.length > challengePageSize) {
      final firstPageRecords = challengeRecords.take(challengePageSize).toList();
      profile = profile!.copyWith(challengeRecords: firstPageRecords);
      print('🔍 ProfileViewModel: 挑战数据已清理，保留 ${firstPageRecords.length} 条记录');
    }
    
    // 重置分页状态到第一页
    checkinCurrentPage = 1;
    challengeCurrentPage = 1;
    hasMoreCheckins = checkinRecords.length < checkinTotal;
    hasMoreChallenges = challengeRecords.length < challengeTotal;
    
    // 重置加载状态
    isLoadingCheckins = false;
    isLoadingChallenges = false;
    
    print('🔍 ProfileViewModel: 分页数据清理完成');
    print('🔍 ProfileViewModel: 打卡记录数: ${checkinRecords.length}, 挑战记录数: ${challengeRecords.length}');
    
    // 通知监听器更新UI
    notifyListeners();
  }

  /// 清理所有数据（用于退出登录时）
  void clearAllData() {
    print('🔍 ProfileViewModel: 清理所有数据');
    
    // 清理用户资料
    profile = null;
    
    // 清理错误状态
    error = null;
    
    // 清理激活相关状态
    activationError = null;
    activationSuccessMessage = null;
    
    // 清理用户信息更新相关状态
    profileUpdateError = null;
    profileUpdateSuccessMessage = null;
    
    // 清理账号删除相关状态
    accountDeletionError = null;
    accountDeletionSuccessMessage = null;
    
    // 清理分页状态
    activateTotal = 0;
    activateCurrentPage = 1;
    checkinTotal = 0;
    checkinCurrentPage = 1;
    challengeTotal = 0;
    challengeCurrentPage = 1;
    
    // 清理时间戳
    _lastFullRefreshTime = null;
    
    // 重置加载状态
    isLoading = false;
    isLoadingActivate = false;
    isLoadingCheckins = false;
    isLoadingChallenges = false;
    
    // 重置操作状态
    isSubmittingActivation = false;
    isUpdatingProfile = false;
    isDeletingAccount = false;
    
    print('🔍 ProfileViewModel: 所有数据已清理完成');
    
    // 通知监听器更新UI
    notifyListeners();
  }

  // 私有方法：设置状态
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }


}
