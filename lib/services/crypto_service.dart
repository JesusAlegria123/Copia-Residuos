import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../core/exceptions.dart';

class CryptoService {
  static const String _jwtSecret =
      'your-super-secret-key-change-in-production';

  static const Duration _accessTokenExpiry = Duration(minutes: 15);
  static const Duration _refreshTokenExpiry = Duration(days: 7);

  static String hashPassword(String password) {
    try {
      return BCrypt.hashpw(password, BCrypt.gensalt(rounds: 10));
    } catch (e) {
      throw AppException(
        message: 'Error al procesar la contraseña.',
        code: 'HASH_ERROR',
        originalError: e.toString(),
      );
    }
  }

  static bool verifyPassword(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } catch (e) {
      throw AppException(
        message: 'Error al verificar la contraseña.',
        code: 'VERIFY_ERROR',
        originalError: e.toString(),
      );
    }
  }

  static String generateAccessToken({
    required String userId,
    required String email,
    required String rol,
  }) {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(_accessTokenExpiry);

      final jwt = JWT({
        'sub': userId,
        'email': email,
        'rol': rol,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
        'type': 'access',
      });

      return jwt.sign(SecretKey(_jwtSecret));
    } catch (e) {
      throw AppException(
        message: 'Error al generar token de acceso.',
        code: 'TOKEN_GENERATION_ERROR',
        originalError: e.toString(),
      );
    }
  }

  static String generateRefreshToken({
    required String userId,
  }) {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(_refreshTokenExpiry);

      final jwt = JWT({
        'sub': userId,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
        'type': 'refresh',
      });

      return jwt.sign(SecretKey(_jwtSecret));
    } catch (e) {
      throw AppException(
        message: 'Error al generar token de refresco.',
        code: 'REFRESH_TOKEN_ERROR',
        originalError: e.toString(),
      );
    }
  }

  static Map<String, dynamic> verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      throw AuthException.tokenExpired();
    } on JWTException {
      throw AuthException.tokenInvalid();
    } catch (e) {
      throw AuthException.tokenInvalid();
    }
  }

  static Map<String, dynamic>? decodeTokenWithoutVerification(String token) {
    try {
      final jwt = JWT.decode(token);
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static String? getUserIdFromToken(String token) {
    try {
      final payload = decodeTokenWithoutVerification(token);
      return payload?['sub'] as String?;
    } catch (e) {
      return null;
    }
  }

  static bool isTokenExpired(String token) {
    try {
      final payload = decodeTokenWithoutVerification(token);
      if (payload == null) return true;

      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiresAt.isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  static String hashToken(String token) {
    try {
      return sha256.convert(utf8.encode(token)).toString();
    } catch (e) {
      throw AppException(
        message: 'Error al generar hash del token.',
        code: 'TOKEN_HASH_ERROR',
        originalError: e.toString(),
      );
    }
  }

  static int getTokenExpiryInSeconds(String token) {
    try {
      final payload = decodeTokenWithoutVerification(token);
      if (payload == null) return -1;

      final exp = payload['exp'] as int?;
      if (exp == null) return -1;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp - now;
    } catch (e) {
      return -1;
    }
  }

  static bool shouldRefreshToken(String token) {
    final secondsLeft = getTokenExpiryInSeconds(token);
    return secondsLeft > 0 && secondsLeft < 120;
  }
}