class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final userJson = payload['user'] is Map<String, dynamic>
        ? payload['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final token = (payload['token'] ?? payload['accessToken'] ?? '').toString();
    if (token.isEmpty) {
      throw const FormatException(
        'La respuesta de autenticación no incluye token.',
      );
    }
    return AuthSession(token: token, user: AppUser.fromJson(userJson));
  }
}

class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? json['username'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
  );
}
