import 'dart:math';

class CheckinProduct {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;    // 可选，null表示使用随机图标
  final String? videoUrl;   // 可选，null表示使用本地默认视频

  CheckinProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.videoUrl,
  });

  // 固定的路由名称
  String get routeName => "/training_list";

  // 智能图标选择：优先使用API图标，否则使用随机图标
  String get displayIcon {
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      return iconUrl!; // 使用API提供的图标
    }
    return randomIcon; // 使用随机图标
  }

  // 随机生成图标的方法 - 使用通用图标，避免运动属性冲突
  String get randomIcon {
    final icons = [
      0xe3e9,  // flash_on - 闪电 - 能量
      0xe838,  // star - 星星 - 优秀
      0xe87d,  // favorite - 心形 - 喜爱
      0xe3e8,  // bolt - 闪电 - 活力
      0xe82c,  // local_fire_department - 火焰 - 热情
      0xe80e,  // whatshot - 热门 - 流行
      0xe8e5,  // trending_up - 上升 - 进步
      0xea79,  // emoji_events - 奖杯 - 成就
      0xe7af,  // workspace_premium - 高级 - 品质
      0xe65f,  // auto_awesome - 魔法 - 神奇
      0xea4a,  // psychology - 大脑 - 智慧
      0xeb30,  // sports_score - 分数 - 成绩
      0xe9b9,  // rocket_launch - 火箭 - 起飞
      0xeb6a,  // diamond - 钻石 - 珍贵
      0xea64,  // celebration - 庆祝 - 成功
    ];
    final random = Random();
    return icons[random.nextInt(icons.length)].toString();
  }

  // 智能视频选择：优先使用API视频，否则使用本地默认视频
  String get displayVideo {
    if (videoUrl != null && videoUrl!.isNotEmpty) {
      return videoUrl!; // 使用API提供的视频
    }
    return "assets/video/video1.mp4"; // 使用本地默认视频
  }

  // 业务规则：检查是否有自定义图标
  bool get hasCustomIcon => iconUrl != null && iconUrl!.isNotEmpty;

  // 业务规则：检查是否有自定义视频
  bool get hasCustomVideo => videoUrl != null && videoUrl!.isNotEmpty;

  // 业务规则：检查是否需要回退到本地资源
  bool get needsLocalFallback => !hasCustomIcon || !hasCustomVideo;

  // 业务规则：获取产品显示名称（可扩展为多语言支持）
  String get displayName => name;

  // 业务规则：获取产品描述（可扩展为多语言支持）
  String get displayDescription => description;

  // 业务规则：检查产品是否有效
  bool get isValid => id.isNotEmpty && name.isNotEmpty && description.isNotEmpty;

  // 业务规则：获取产品唯一标识（用于缓存和比较）
  String get uniqueKey => "checkin_product_$id";

  // 业务规则：获取产品摘要信息
  String get summary {
    final words = description.split(' ');
    if (words.length <= 10) return description;
    return '${words.take(10).join(' ')}...';
  }
}

 