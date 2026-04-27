import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/dotenv.dart';

class JwtService {
  JwtService._();

  static String sign({
    required String userId,
    required String email,
  }) {
    final secret = Env.get('JWT_SECRET');
    final issuer = Env.get('JWT_ISSUER', fallback: 'app_auth_api');

    final jwt = JWT(
      {
        'sub': userId,
        'email': email,
      },
      issuer: issuer,
    );

    return jwt.sign(
      SecretKey(secret),
      expiresIn: const Duration(hours: 2),
    );
  }

  static JWT verify(String token) {
    final secret = Env.get('JWT_SECRET');
    return JWT.verify(token, SecretKey(secret));
  }
}