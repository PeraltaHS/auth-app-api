import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static String hash(String password, {required String salt}) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  static bool verify({
    required String password,
    required String salt,
    required String hash,
  }) {
    final newHash = PasswordHasher.hash(password, salt: salt);
    return newHash == hash;
  }
}