class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      roles: rawRoles is List
          ? rawRoles
                .map((role) => role is Map ? role['key']?.toString() : null)
                .whereType<String>()
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'roles': roles.map((key) => {'key': key}).toList(),
  };
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshCookie,
  });

  final String accessToken;
  final AuthUser user;
  final String? refreshCookie;
}
