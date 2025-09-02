class CheckinProductApiModel {
  final String id;
  final String name;
  final String description;
  final String? videoUrl;

  CheckinProductApiModel({
    required this.id,
    required this.name,
    required this.description,
    this.videoUrl,
  });

  factory CheckinProductApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinProductApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'videoUrl': videoUrl,
  };
}

class CheckinListApiModel {
  final List<CheckinProductApiModel> products;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinListApiModel({
    required this.products,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory CheckinListApiModel.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List;
    final products = productsList
        .map((product) => CheckinProductApiModel.fromJson(product as Map<String, dynamic>))
        .toList();
    
    return CheckinListApiModel(
      products: products,
      total: json['total'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
    'products': products.map((product) => product.toJson()).toList(),
    'total': total,
    'currentPage': currentPage,
    'pageSize': pageSize,
  };

  // 分页信息计算
  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
} 