import 'dart:convert';
import 'dart:math';

import 'package:shelf/shelf.dart';

import '../../../../core/security/jwt_service.dart';
import '../../../../core/security/password_hasher.dart';

class AuthController {
  AuthController();

  // Repo em memória (depois trocamos por Postgres)
  // email -> { id, email, salt, hash }
  final Map<String, Map<String, String>> _usersByEmail = {};
  final Random _rng = Random.secure();

  Response _json(int status, Map<String, dynamic> body) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  String _newSalt() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  Future<Response> register(Request req) async {
    final raw = await req.readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final email = (data['email'] ?? '').toString().trim().toLowerCase();
    final password = (data['password'] ?? '').toString();

    if (email.isEmpty || password.isEmpty) {
      return _json(400, {'error': 'email and password are required'});
    }

    if (_usersByEmail.containsKey(email)) {
      return _json(409, {'error': 'email already registered'});
    }

    final id = _newId();
    final salt = _newSalt();
    final hash = PasswordHasher.hash(password, salt: salt);

    _usersByEmail[email] = {
      'id': id,
      'email': email,
      'salt': salt,
      'hash': hash,
    };

    return _json(201, {'message': 'user created', 'userId': id});
  }

  Future<Response> login(Request req) async {
    final raw = await req.readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final email = (data['email'] ?? '').toString().trim().toLowerCase();
    final password = (data['password'] ?? '').toString();

    final user = _usersByEmail[email];
    if (user == null) {
      return _json(401, {'error': 'invalid credentials'});
    }

    final ok = PasswordHasher.verify(
      password: password,
      salt: user['salt']!,
      hash: user['hash']!,
    );

    if (!ok) {
      return _json(401, {'error': 'invalid credentials'});
    }

    final token = JwtService.sign(
      userId: user['id']!,
      email: user['email']!,
    );

    return _json(200, {'token': token});
  }

  Response me(Request req) {
    final userId = req.context['userId'];
    final email = req.context['email'];

    return Response.ok(
      jsonEncode({
        'userId': userId,
        'email': email,
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}