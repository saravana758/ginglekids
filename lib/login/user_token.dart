// user_token.dart

class UserToken {
  final String token;
  final String name;

  UserToken({
    required this.token,
    required this.name,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) {
    return UserToken(
      token: json['data']['token'] ?? '',
      name: json['data']['name'] ?? '',
    );
  }
}
