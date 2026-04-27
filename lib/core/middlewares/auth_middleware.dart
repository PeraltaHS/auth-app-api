import 'package:shelf/shelf.dart';
import '../security/jwt_service.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Missing or invalid Authorization header');
      }

      final token = authHeader.substring('Bearer '.length).trim();

      try {
        final jwt = JwtService.verify(token);
        final payload = jwt.payload as Map<String, dynamic>;

        final updatedRequest = request.change(context: {
          ...request.context,
          'userId': payload['sub'],
          'email': payload['email'],
        });

        return await innerHandler(updatedRequest);
      } catch (_) {
        return Response.forbidden('Invalid token');
      }
    };
  };
}