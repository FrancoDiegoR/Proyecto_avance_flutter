import '../../common/json_utils.dart';

/// Cuenta que devuelve POST /auth/sign-in.
class Account {
  final int id;
  final String email;
  final String fullName;
  final String role;

  Account({required this.id, required this.email, required this.fullName, required this.role});

  /// El backend real y el mock usan nombres distintos (accountId/id, fullName/name): se aceptan ambos.
  factory Account.fromJson(Map<String, dynamic> json) {
    final nested = json['account'] is Map<String, dynamic> ? json['account'] as Map<String, dynamic> : const {};
    return Account(
      id: toInt(json['accountId'] ?? json['id'] ?? nested['id']),
      email: toText(json['email'] ?? nested['email']),
      fullName: toText(json['fullName'] ?? json['name']),
      role: toText(json['role'] ?? nested['role']),
    );
  }

  String get firstName => fullName.trim().split(' ').first;
}
