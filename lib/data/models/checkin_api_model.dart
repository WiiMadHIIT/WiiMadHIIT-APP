class CheckinProductApiModel {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final String? videoUrl;

  CheckinProductApiModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.videoUrl,
  });

  factory CheckinProductApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinProductApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconUrl': iconUrl,
    'videoUrl': videoUrl,
  };
}

class CheckinListApiModel {
  final List<CheckinProductApiModel> products;

  CheckinListApiModel({
    required this.products,
  });

  factory CheckinListApiModel.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List;
    final products = productsList
        .map((product) => CheckinProductApiModel.fromJson(product as Map<String, dynamic>))
        .toList();
    
    return CheckinListApiModel(products: products);
  }

  Map<String, dynamic> toJson() => {
    'products': products.map((product) => product.toJson()).toList(),
  };
} 