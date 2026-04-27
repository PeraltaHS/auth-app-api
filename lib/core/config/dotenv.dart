import 'package:dotenv/dotenv.dart';

class Env {
  Env._();

  static final DotEnv _dotenv = DotEnv();
  static bool _loaded = false;

  static void load() {
    if (_loaded) return;

    _dotenv.load();
    _loaded = true;
  }

  static String get(String key, {String? fallback}) {
    final v = _dotenv[key];

    if (v == null || v.isEmpty) {
      if (fallback != null) return fallback;
      throw StateError('Missing env var: $key');
    }

    return v;
  }

  static int getInt(String key, {required int fallback}) {
    final v = _dotenv[key];

    if (v == null || v.isEmpty) return fallback;

    return int.parse(v);
  }
}