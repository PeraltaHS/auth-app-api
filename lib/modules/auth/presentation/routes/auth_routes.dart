import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router authRoutes() {
  final router = Router();

  router.post('/register', (Request req) async {
    final body = await req.readAsString();
    final data = body.isEmpty ? <String, dynamic>{} : jsonDecode(body);

    return Response.ok(
      jsonEncode({
        "message": "registered",
        "data": {
          "name": data["name"],
          "email": data["email"]
        }
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  router.post('/login', (Request req) async {
    return Response.ok(
      jsonEncode({
        "message": "logged_in",
        "data": {
          "accessToken": "fake-access-token",
          "refreshToken": "fake-refresh-token"
        }
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  return router;
}
