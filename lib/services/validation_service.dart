import '../core/exceptions.dart';

class ValidationService {
  static const String _emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  static String validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      throw ValidationException.fieldRequired('Email');
    }

    final trimmedEmail = email.trim().toLowerCase();

    if (!RegExp(_emailPattern).hasMatch(trimmedEmail)) {
      throw ValidationException.invalidEmail();
    }

    return trimmedEmail;
  }

  static String validateName(String? name) {
    if (name == null || name.isEmpty) {
      throw ValidationException.fieldRequired('Nombre');
    }

    final trimmedName = name.trim();

    if (trimmedName.length < 3) {
      throw ValidationException(
        message: 'El nombre debe tener al menos 3 caracteres.',
        code: 'NAME_TOO_SHORT',
      );
    }

    return trimmedName;
  }
}