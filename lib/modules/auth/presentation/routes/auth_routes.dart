import 'dart:convert';
import 'dart:math';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Router authRoutes(Connection db) {
  final router = Router();

  router.post('/register', (Request req) async {
    final body = await req.readAsString();
    final data = body.isEmpty ? <String, dynamic>{} : jsonDecode(body);

    final name = data['name']?.toString() ?? '';
    final email = data['email']?.toString().toLowerCase() ?? '';
    final password = data['password']?.toString() ?? '';

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return Response(400,
          body: jsonEncode({'error': 'name, email and password required'}),
          headers: {'content-type': 'application/json'});
    }

    final existing = await db.execute(
      Sql.named('select id from users where email = @email'),
      parameters: {'email': email},
    );

    if (existing.isNotEmpty) {
      return Response(409,
          body: jsonEncode({'error': 'email already exists'}),
          headers: {'content-type': 'application/json'});
    }

    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    final inserted = await db.execute(
      Sql.named('''
        insert into users (name, email, password_hash)
        values (@name, @email, @password_hash)
        returning id
      '''),
      parameters: {
        'name': name,
        'email': email,
        'password_hash': passwordHash
      },
    );

    final userId = inserted.first.first.toString();

    final jwt = JWT({'sub': userId, 'email': email});
    final accessToken = jwt.sign(SecretKey('super_secret_key'));

    final refreshToken = _generateRefreshToken();

    return Response.ok(
      jsonEncode({
        'user': {'id': userId, 'name': name, 'email': email},
        'accessToken': accessToken,
        'refreshToken': refreshToken
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  router.post('/login', (Request req) async {
    final body = await req.readAsString();
    final data = body.isEmpty ? <String, dynamic>{} : jsonDecode(body);

    final email = data['email']?.toString().toLowerCase() ?? '';
    final password = data['password']?.toString() ?? '';

    final rows = await db.execute(
      Sql.named('select id, name, password_hash from users where email = @email'),
      parameters: {'email': email},
    );

    if (rows.isEmpty) {
      return Response(401,
          body: jsonEncode({'error': 'invalid credentials'}),
          headers: {'content-type': 'application/json'});
    }

    final row = rows.first;
    final userId = row[0].toString();
    final name = row[1].toString();
    final passwordHash = row[2].toString();

    if (!BCrypt.checkpw(password, passwordHash)) {
      return Response(401,
          body: jsonEncode({'error': 'invalid credentials'}),
          headers: {'content-type': 'application/json'});
    }

    final jwt = JWT({'sub': userId, 'email': email});
    final accessToken = jwt.sign(SecretKey('super_secret_key'));

    final refreshToken = _generateRefreshToken();

    return Response.ok(
      jsonEncode({
        'user': {'id': userId, 'name': name, 'email': email},
        'accessToken': accessToken,
        'refreshToken': refreshToken
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

String _generateRefreshToken() {
  final rnd = Random.secure();
  final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
  return base64UrlEncode(bytes);
}
