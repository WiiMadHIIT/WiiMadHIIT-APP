import '../entities/checkin_product.dart';

class CheckinService {
  /// 获取推荐产品列表
  List<CheckinProduct> getRecommendedProducts(List<CheckinProduct> products) {
    // 简单的推荐逻辑：返回所有有效产品
    return products.where((product) => product.isValid).toList();
  }

  /// 根据产品名称搜索
  List<CheckinProduct> searchProducts(List<CheckinProduct> products, String query) {
    if (query.isEmpty) return products;
    
    final lowercaseQuery = query.toLowerCase();
    return products.where((product) => 
      product.name.toLowerCase().contains(lowercaseQuery) ||
      product.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// 获取有自定义图标的产品
  List<CheckinProduct> getProductsWithCustomIcons(List<CheckinProduct> products) {
    return products.where((product) => product.hasCustomIcon).toList();
  }

  /// 获取有自定义视频的产品
  List<CheckinProduct> getProductsWithCustomVideos(List<CheckinProduct> products) {
    return products.where((product) => product.hasCustomVideo).toList();
  }

  /// 获取需要本地回退的产品
  List<CheckinProduct> getProductsNeedingLocalFallback(List<CheckinProduct> products) {
    return products.where((product) => product.needsLocalFallback).toList();
  }

  /// 验证产品数据完整性
  bool validateProductData(List<CheckinProduct> products) {
    return products.every((product) => product.isValid);
  }

  /// 获取产品统计信息
  Map<String, int> getProductStatistics(List<CheckinProduct> products) {
    return {
      'total': products.length,
      'withCustomIcons': getProductsWithCustomIcons(products).length,
      'withCustomVideos': getProductsWithCustomVideos(products).length,
      'needingFallback': getProductsNeedingLocalFallback(products).length,
    };
  }
} 