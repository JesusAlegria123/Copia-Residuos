import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════
// MODELO DE USUARIO
// ══════════════════════════════════════════════════
class UserModel {
  final String email;
  final String nombre;
  final String primerApellido;
  final String segundoApellido;
  final String rol;
  final String avatar;

  const UserModel({
    required this.email,
    required this.nombre,
    required this.primerApellido,
    required this.segundoApellido,
    required this.rol,
    required this.avatar,
  });

  bool get esAdmin => rol == 'Administrador';

  // Getter para obtener el nombre completo cuando lo necesites
  String get nombreCompleto => '$nombre $primerApellido $segundoApellido'.trim();
}

// ══════════════════════════════════════════════════
// SERVICIO DE AUTENTICACIÓN
// ══════════════════════════════════════════════════
class AuthService {
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedEmail = 'saved_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail  = 'user_email';
  static const String _keyUserRol    = 'user_rol';
  static const String _keyUserNombre = 'user_nombre';
  static const String _keyUserPrimerApellido = 'user_primer_apellido';
  static const String _keyUserSegundoApellido = 'user_segundo_apellido';

  /// Base de datos mock — mutable para permitir registros nuevos
  static final Map<String, Map<String, String>> _usuariosMock = {
    'admin@unsaac.edu.pe': {
      'password': 'Admin123',
      'rol'     : 'Administrador',
      'nombre'  : 'Admin',
      'primer_apellido': 'UNSAAC',
      'segundo_apellido': '',
    },
    'usuario@test.com': {
      'password': '123456',
      'rol'     : 'Usuario',
      'nombre'  : 'Juan',
      'primer_apellido': 'Quispe',
      'segundo_apellido': 'Huanca',
    },
    'invitado@demo.com': {
      'password': 'demo123',
      'rol'     : 'Invitado',
      'nombre'  : 'Visitante',
      'primer_apellido': 'Demo',
      'segundo_apellido': '',
    },
    'municipio@cusco.gob.pe': {
      'password': 'Cusco2025',
      'rol'     : 'Municipalidad',
      'nombre'  : 'Municipalidad',
      'primer_apellido': 'Cusco',
      'segundo_apellido': '',
    },
  };

  /// REGISTRA UN NUEVO USUARIO - Recibe los 3 campos por separado
  Future<UserModel?> registrar({
    required String nombre,
    required String primerApellido,
    required String segundoApellido,
    required String email,
    required String password,
    required String rol,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final emailLower = email.trim().toLowerCase();
    if (_usuariosMock.containsKey(emailLower)) return null; // ya existe

    // Guarda los 3 campos por separado en la "base de datos"
    _usuariosMock[emailLower] = {
      'password': password.trim(),
      'rol'     : rol,
      'nombre'  : nombre.trim(),
      'primer_apellido': primerApellido.trim(),
      'segundo_apellido': segundoApellido.trim(),
    };

    final user = UserModel(
      email : emailLower,
      nombre: nombre.trim(),
      primerApellido: primerApellido.trim(),
      segundoApellido: segundoApellido.trim(),
      rol   : rol,
      avatar: nombre.trim()[0].toUpperCase(),
    );
    await _guardarSesion(user: user, recordarme: false);
    return user;
  }

  /// VERIFICA SI UN EMAIL YA ESTÁ REGISTRADO
  bool emailExiste(String email) =>
      _usuariosMock.containsKey(email.trim().toLowerCase());

  /// INICIO DE SESIÓN
  Future<UserModel?> login({
    required String email,
    required String password,
    bool recordarme = false,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final emailLower = email.trim().toLowerCase();
    final data = _usuariosMock[emailLower];
    if (data != null && data['password'] == password.trim()) {
      final user = UserModel(
        email : emailLower,
        nombre: data['nombre']!,
        primerApellido: data['primer_apellido'] ?? '',
        segundoApellido: data['segundo_apellido'] ?? '',
        rol   : data['rol']!,
        avatar: data['nombre']![0].toUpperCase(),
      );
      await _guardarSesion(user: user, recordarme: recordarme);
      return user;
    }
    return null;
  }

  /// CIERRA SESIÓN
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRol);
    await prefs.remove(_keyUserNombre);
    await prefs.remove(_keyUserPrimerApellido);
    await prefs.remove(_keyUserSegundoApellido);
  }

  /// GUARDA LA SESIÓN EN SHARED PREFERENCES
  Future<void> _guardarSesion({
    required UserModel user,
    required bool recordarme,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyRememberMe, recordarme);
    await prefs.setString(_keyUserEmail,  user.email);
    await prefs.setString(_keyUserRol,    user.rol);
    await prefs.setString(_keyUserNombre, user.nombre);
    await prefs.setString(_keyUserPrimerApellido, user.primerApellido);
    await prefs.setString(_keyUserSegundoApellido, user.segundoApellido);
    if (recordarme) {
      await prefs.setString(_keySavedEmail, user.email);
    } else {
      await prefs.remove(_keySavedEmail);
    }
  }

  /// CARGA EL EMAIL GUARDADO
  Future<String?> cargarEmailGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyRememberMe) ?? false) {
      return prefs.getString(_keySavedEmail);
    }
    return null;
  }

  /// OBTIENE EL ESTADO DE "RECORDARME"
  Future<bool> obtenerRecordarme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// OBTIENE LA SESIÓN ACTIVA
  Future<UserModel?> obtenerSesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!loggedIn) return null;
    final email  = prefs.getString(_keyUserEmail)  ?? '';
    final rol    = prefs.getString(_keyUserRol)    ?? '';
    final nombre = prefs.getString(_keyUserNombre) ?? '';
    final primerApellido = prefs.getString(_keyUserPrimerApellido) ?? '';
    final segundoApellido = prefs.getString(_keyUserSegundoApellido) ?? '';
    if (email.isEmpty) return null;
    return UserModel(
      email : email,
      nombre: nombre,
      primerApellido: primerApellido,
      segundoApellido: segundoApellido,
      rol   : rol,
      avatar: nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
    );
  }

  /// VERIFICA SI EL USUARIO ES ADMIN
  Future<bool> esUsuarioAdmin() async {
    final user = await obtenerSesionActiva();
    return user?.esAdmin ?? false;
  }
}