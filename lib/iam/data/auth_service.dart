import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/api_config.dart';
import '../domain/account.dart';

/// Bounded context IAM: inicio de sesion contra POST /auth/sign-in.
class AuthService {
  Future<Account> signIn(String email, String password) async {
    final response = await http.post(
      ApiConfig.uri('auth/sign-in'),
      headers: ApiConfig.jsonHeaders,
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return Account.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
