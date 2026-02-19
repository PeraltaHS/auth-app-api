import 'package:shelf_router/shelf_router.dart';

import '../../application/usecases/login_usecase.dart';
import '../../application/usecases/register_usecase.dart';
import '../../infra/repositories/auth_repository_memory.dart';
import '../controllers/auth_controller.dart';

Router authRoutes() {
  final repo = AuthRepositoryMemory();
  final registerUsecase = RegisterUsecase(repo);
  final loginUsecase = LoginUsecase(repo);

  final controller = AuthController(
    register: registerUsecase,
    login: loginUsecase,
  );

  final router = Router();

  router.post('/register', controller.register);
  router.post('/login', controller.login);

  return router;
}
