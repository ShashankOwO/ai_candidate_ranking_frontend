class UserModel {
  final int userId;
  final String username;
  final String email;

  const UserModel({
    required this.userId,
    required this.username,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? json['id'] ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
