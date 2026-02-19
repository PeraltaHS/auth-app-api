import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../application/dtos/login_dto.dart';
import '../../application/dtos/register_dto.dart';
import '../../application/usecases/login_usecase.dart';
import '../../application/usecases/register_usecase.dart';

class AuthController {
  final RegisterUsecase _register;
  final LoginUsecase _login;

  AuthController({
    required RegisterUsecase register,
    required LoginUsecase login,
  })  : _register = register,
        _login = login;

  Future<Response> register(Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final name = (data['name'] ?? '').toString();
      final email = (data['email'] ?? '').toString();
      final password = (data['password'] ?? '').toString();

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return _json(400, {'error': 'invalid_payload'});
      }

      await _register.call(
        RegisterDto(
          name: name,
          email: email,
          password: password,
        ),
      );

      return _json(201, {'message': 'registered'});
    } catch (e) {
      return _json(400, {'error': e.toString()});
    }
  }

  Future<Response> login(Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final email = (data['email'] ?? '').toString();
      final password = (data['password'] ?? '').toString();

      if (email.isEmpty || password.isEmpty) {
        return _json(400, {'error': 'invalid_payload'});
      }

      final tokens = await _login.call(
        LoginDto(
          email: email,
          password: password,
        ),
      );

      return _json(200, {
        'message': 'logged_in',
        'data': tokens,
      });
    } catch (e) {
      return _json(401, {'error': e.toString()});
    }
  }

  Response _json(int status, Map<String, dynamic> body) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
