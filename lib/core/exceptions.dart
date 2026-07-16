// ══════════════════════════════════════════════════════════════════
// EXCEPCIONES PERSONALIZADAS
// ══════════════════════════════════════════════════════════════════

class AppException implements Exception {
  final String message;
  final String? code;
  final String? originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Código: $code)' : ''}';
}

class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    String? originalError,
  }) : super(message: message, code: code, originalError: originalError);

  factory AuthException.invalidCredentials() {
    return AuthException(
      message: 'Credenciales inválidas.',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthException.userNotFound() {
    return AuthException(
      message: 'Usuario no encontrado.',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthException.emailAlreadyExists() {
    return AuthException(
      message: 'El email ya está registrado.',
      code: 'EMAIL_EXISTS',
    );
  }

  factory AuthException.tokenExpired() {
    return AuthException(
      message: 'La sesión ha expirado. Inicia sesión nuevamente.',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthException.tokenInvalid() {
    return AuthException(
      message: 'Token inválido.',
      code: 'TOKEN_INVALID',
    );
  }
}

class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    String? originalError,
  }) : super(message: message, code: code, originalError: originalError);

  factory ValidationException.invalidEmail() {
    return ValidationException(
      message: 'El formato del email no es válido.',
      code: 'INVALID_EMAIL',
    );
  }

  factory ValidationException.fieldRequired(String field) {
    return ValidationException(
      message: 'El campo "$field" es obligatorio.',
      code: 'FIELD_REQUIRED',
    );
  }
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    String? originalError,
  }) : super(message: message, code: code, originalError: originalError);

  factory NetworkException.noInternet() {
    return NetworkException(
      message: 'No hay conexión a internet.',
      code: 'NO_INTERNET',
    );
  }
}

class ExceptionHandler {
  static AppException handle(dynamic error, String source) {
    if (error is AppException) {
      return error;
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return NetworkException.noInternet();
    }

    return AppException(
      message: 'Error inesperado en $source.',
      code: 'UNKNOWN_ERROR',
      originalError: error.toString(),
    );
  }
}