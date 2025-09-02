class ActivationRequest {
  final String productId;
  final String activationCode;
  final DateTime submittedAt;

  ActivationRequest({
    required this.productId,
    required this.activationCode,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  // 业务方法
  bool get isValid => productId.isNotEmpty && activationCode.isNotEmpty;
  
  // 验证激活码格式
  bool get isCodeFormatValid {
    // 激活码至少6位，包含字母和数字
    if (activationCode.length < 6) return false;
    
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(activationCode);
    final hasDigit = RegExp(r'[0-9]').hasMatch(activationCode);
    
    return hasLetter && hasDigit;
  }

  // 获取提交时间描述
  String get submittedTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(submittedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // 转换为API请求格式
  Map<String, dynamic> toApiRequest() {
    return {
      'productId': productId,
      'activationCode': activationCode,
    };
  }

  // 从API请求格式创建
  factory ActivationRequest.fromApiRequest(Map<String, dynamic> json) {
    return ActivationRequest(
      productId: json['productId'] as String,
      activationCode: json['activationCode'] as String,
    );
  }

  @override
  String toString() {
    return 'ActivationRequest(productId: $productId, activationCode: $activationCode, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivationRequest &&
        other.productId == productId &&
        other.activationCode == activationCode;
  }

  @override
  int get hashCode {
    return productId.hashCode ^ activationCode.hashCode;
  }
}
