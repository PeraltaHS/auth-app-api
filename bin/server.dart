import 'dart:convert';
import 'dart:io';

import 'package:app_auth_api/modules/auth/presentation/routes/auth_routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final router = Router();

  router.get('/', (Request req) {
    return Response.ok(
      'AuthApp API online',
      headers: {'content-type': 'text/plain; charset=utf-8'},
    );
  });

  router.get('/health', (Request req) {
    return Response.ok(
      jsonEncode({'status': 'ok'}),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  router.mount('/auth', authRoutes().call);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  stdout.writeln('http://localhost:${server.port}');
}
