class VerificationCodeResponseApiModel {
  final String email;
  final int expireTime;
  final int resendTime;

  VerificationCodeResponseApiModel({
    required this.email,
    required this.expireTime,
    required this.resendTime,
  });

  factory VerificationCodeResponseApiModel.fromJson(Map<String, dynamic> json) {
    return VerificationCodeResponseApiModel(
      email: json['email'] as String,
      expireTime: json['expireTime'] as int,
      resendTime: json['resendTime'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'expireTime': expireTime,
    'resendTime': resendTime,
  };
}

class LoginVerifyResponseApiModel {
  final String token;
  final String refreshToken;
  final int issuedAt; // ms timestamp
  final int expiresIn; // ms timestamp (过期时间戳)

  LoginVerifyResponseApiModel({
    required this.token,
    required this.refreshToken,
    required this.issuedAt,
    required this.expiresIn,
  });

  factory LoginVerifyResponseApiModel.fromJson(Map<String, dynamic> json) {
    return LoginVerifyResponseApiModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      issuedAt: json['issuedAt'] as int,
      expiresIn: json['expiresIn'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'issuedAt': issuedAt,
    'expiresIn': expiresIn,
  };
}

class RegisterVerifyResponseApiModel {
  final String status;

  RegisterVerifyResponseApiModel({
    required this.status,
  });

  factory RegisterVerifyResponseApiModel.fromJson(Map<String, dynamic> json) {
    return RegisterVerifyResponseApiModel(
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
  };
}

