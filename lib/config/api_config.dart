import 'dart:io';

/// URL base del backend Express.
/// - Emulador Android: 10.0.2.2 apunta al localhost de la PC
/// - iOS simulador / Windows / Web: localhost
/// - Dispositivo físico: usa la IP de tu PC en la red local
class ApiConfig {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
