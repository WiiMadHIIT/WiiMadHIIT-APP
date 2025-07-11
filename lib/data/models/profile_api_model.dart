class ProfileApiModel {
  final String userId;
  final String username;
  final String email;

  ProfileApiModel({
    required this.userId,
    required this.username,
    required this.email,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'email': email,
  };
}