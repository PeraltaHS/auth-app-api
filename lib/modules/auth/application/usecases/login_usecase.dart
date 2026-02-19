import '../dtos/login_dto.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repo;

  LoginUsecase(this._repo);

  Future<Map<String, String>> call(LoginDto dto) async {
    return _repo.login(
      email: dto.email,
      password: dto.password,
    );
  }
}
