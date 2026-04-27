import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  router.get('/', (Request request) {
    return Response.ok('API App Auth rodando com sucesso!');
  });

  router.get('/login', (Request request) {
    return Response.ok('Rota de login funcionando!');
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

  print('Servidor rodando em http://${server.address.host}:${server.port}');
}