import 'dart:math';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryMemory implements AuthRepository {
  final Map<String, Map<String, String>> _usersByEmail = {};

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_usersByEmail.containsKey(normalizedEmail)) {
      throw Exception('email_already_registered');
    }

    _usersByEmail[normalizedEmail] = {
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
    };
  }

  @override
  Future<Map<String, String>> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _usersByEmail[normalizedEmail];

    if (user == null) {
      throw Exception('invalid_credentials');
    }

    if (user['password'] != password) {
      throw Exception('invalid_credentials');
    }

    return {
      'accessToken': _randomToken(),
      'refreshToken': _randomToken(),
    };
  }

  String _randomToken() {
    final r = Random.secure();
    final bytes = List<int>.generate(32, (_) => r.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
