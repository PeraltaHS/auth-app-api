import '../dtos/register_dto.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repo;

  RegisterUsecase(this._repo);

  Future<void> call(RegisterDto dto) async {
    await _repo.register(
      name: dto.name,
      email: dto.email,
      password: dto.password,
    );
  }
}
