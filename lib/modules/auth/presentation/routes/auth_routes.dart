import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../../core/middlewares/auth_middleware.dart';
import '../controllers/auth_controller.dart';

Router authRoutes() {
  final router = Router();
  final controller = AuthController();

  router.post('/register', controller.register);
  router.post('/login', controller.login);

  router.get(
    '/me',
    Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(controller.me),
  );

  return router;
}