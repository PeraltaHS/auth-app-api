import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:app_auth_api/modules/auth/presentation/routes/auth_routes.dart';

Middleware corsMiddleware({
  String allowOrigin = '*',
  List<String> allowHeaders = const ['content-type', 'authorization'],
  List<String> allowMethods = const ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method.toUpperCase() == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'access-control-allow-origin': allowOrigin,
            'access-control-allow-methods': allowMethods.join(', '),
            'access-control-allow-headers': allowHeaders.join(', '),
            'access-control-allow-credentials': 'true',
          },
        );
      }

      final response = await innerHandler(request);

      return response.change(headers: {
        ...response.headers,
        'access-control-allow-origin': allowOrigin,
        'access-control-allow-methods': allowMethods.join(', '),
        'access-control-allow-headers': allowHeaders.join(', '),
        'access-control-allow-credentials': 'true',
      });
    };
  };
}

Future<void> main() async {
  final env = dotenv.DotEnv()..load();

  final db = await Connection.open(
    Endpoint(
      host: env['DB_HOST'] ?? '127.0.0.1',
      port: int.parse(env['DB_PORT'] ?? '5432'),
      database: env['DB_NAME'] ?? 'authapp',
      username: env['DB_USER'] ?? 'postgres',
      password: env['DB_PASSWORD'] ?? '',
    ),
    settings: const ConnectionSettings(
      sslMode: SslMode.disable,
    ),
  );

  await db.execute('select 1');

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

  router.mount('/auth/', authRoutes(db));

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  stdout.writeln('http://localhost:${server.port}');
}
