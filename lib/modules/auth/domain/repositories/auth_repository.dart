abstract class AuthRepository {
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Map<String, String>> login({
    required String email,
    required String password,
  });
}
