class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, {this.code = 'APP_ERROR'});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
