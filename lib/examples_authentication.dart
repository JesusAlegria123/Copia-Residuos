/// Archivo de Referencia: Ejemplos de Uso del Sistema de Autenticación
///
/// Este archivo contiene ejemplos prácticos de cómo usar cada parte del sistema.
/// ¡NO EJECUTES ESTE ARCHIVO! Es solo referencia educativa.

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 1: INICIALIZAR LA APP
// ══════════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:my_app_residuos/services/supabase_service.dart';

void main() async {
  // 1. Asegurar que bindings están inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. IMPORTANTE: Inicializar Supabase ANTES de correr la app
  //    Sin esto, Supabase no funcionará
  try {
    await SupabaseService.init();
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('❌ Error iniciando Supabase: $e');
    // Mostrar error al usuario
    rethrow;
  }

  runApp(const UnsaacApp());
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 2: REGISTRAR UN USUARIO
// ══════════════════════════════════════════════════════════════════════════════════

import 'package:my_app_residuos/services/auth_service.dart';
import 'package:my_app_residuos/core/exceptions.dart';

Future<void> ejemploRegistro() async {
  final authService = AuthService();

  try {
    // Registrar un nuevo usuario
    final nuevoUsuario = await authService.signup(
      email: 'juan.perez@example.com',
      password: 'SecurePass123!@#', // Debe cumplir requisitos
      nombre: 'Juan Pérez Quispe',
      rol: 'Usuario',
    );

    print('✅ Usuario registrado:');
    print('   Email: ${nuevoUsuario.email}');
    print('   Nombre: ${nuevoUsuario.nombre}');
    print('   ID: ${nuevoUsuario.id}');
    print('   Rol: ${nuevoUsuario.rol}');

    // El usuario está registrado pero NO está autenticado
    // Debe hacer login después del registro
  } on AuthException catch (e) {
    print('❌ Error de autenticación: ${e.message}');
    print('   Código: ${e.code}');
    // Ejemplos de errores posibles:
    // - "Email already exists"
    // - "Weak password"
  } on ValidationException catch (e) {
    print('⚠️ Error de validación: ${e.message}');
    // Ejemplos:
    // - "Invalid email format"
    // - "Password too short"
    // - "Name contains invalid characters"
  } on NetworkException catch (e) {
    print('🌐 Error de red: ${e.message}');
  } on AppException catch (e) {
    print('❌ Error general: ${e.message}');
  }
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 3: LOGIN SEGURO
// ══════════════════════════════════════════════════════════════════════════════════

Future<void> ejemploLogin() async {
  final authService = AuthService();

  try {
    // Login con email y contraseña
    final usuario = await authService.login(
      email: 'juan.perez@example.com',
      password: 'SecurePass123!@#',
    );

    print('✅ Login exitoso!');
    print('   Bienvenido: ${usuario.nombre}');
    print('   Email: ${usuario.email}');
    print('   Rol: ${usuario.rol}');

    // En este punto:
    // - Access Token guardado en almacenamiento seguro (15 min válido)
    // - Refresh Token guardado en almacenamiento seguro (7 días válido)
    // - Información de usuario guardada
    // - Login registrado en auditoría

    // Navegar a HomeScreen
    // Navigator.pushReplacementNamed(context, '/home');
  } on AuthException catch (e) {
    print('❌ Error de login: ${e.message}');
    // Mensajes seguros que NO exponen detalles internos:
    // - "Invalid credentials"
    // - "User not found"
    // - "User account is inactive"
    // - "Session expired"
  } on ValidationException catch (e) {
    print('⚠️ Validación fallida: ${e.message}');
  } on NetworkException catch (e) {
    print('🌐 Problema de conexión: ${e.message}');
  }
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 4: VERIFICAR SESIÓN ACTIVA (en StatefulWidget)
// ══════════════════════════════════════════════════════════════════════════════════

class HomeScreenExample extends StatefulWidget {
  const HomeScreenExample({Key? key}) : super(key: key);

  @override
  State<HomeScreenExample> createState() => _HomeScreenExampleState();
}

class _HomeScreenExampleState extends State<HomeScreenExample> {
  final _authService = AuthService();
  late Future<void> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    try {
      final session = await _authService.obtenerSesionActiva();

      if (session == null) {
        // No hay sesión válida - ir a login
        print('⚠️ No hay sesión activa');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // Sesión válida
      print('✅ Sesión activa para: ${session.user.nombre}');

      // Verificar si token está a punto de expirar
      if (session.shouldRefreshToken) {
        print('🔄 Token a punto de expirar, refrescando...');
        final newSession = await _authService.refreshAccessToken();
        print('✅ Token refrescado');
      }
    } catch (e) {
      print('❌ Error verificando sesión: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error al verificar sesión')),
          );
        }

        // Sesión verificada, mostrar contenido
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: const Center(child: Text('Contenido principal')),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 5: LOGOUT SEGURO
// ══════════════════════════════════════════════════════════════════════════════════

Future<void> ejemploLogout(BuildContext context) async {
  final authService = AuthService();

  try {
    // Logout revoca tokens en servidor y limpia almacenamiento local
    await authService.logout();

    print('✅ Logout exitoso');
    print('   - Tokens revocados en servidor');
    print('   - Almacenamiento local limpiado');

    // Navegar a LoginScreen
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    print('⚠️ Error en logout: $e');
    // Aun así navegar a login para seguridad
    Navigator.pushReplacementNamed(context, '/login');
  }
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 6: REFRESCAR TOKEN AUTOMÁTICAMENTE
// ══════════════════════════════════════════════════════════════════════════════════

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  final _authService = AuthService();
  Timer? _refreshTimer;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  Future<void> iniciarGestionDeSesion() async {
    // Verificar sesión inicial
    final session = await _authService.obtenerSesionActiva();
    if (session == null) return;

    // Configurar timer para refrescar token cada 10 minutos
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      try {
        final newSession = await _authService.refreshAccessToken();
        print('🔄 Token refrescado automáticamente');
      } catch (e) {
        print('⚠️ Error refrescando token: $e');
        // El siguiente request fallará y llevará al usuario a login
      }
    });
  }

  void detenerGestionDeSesion() {
    _refreshTimer?.cancel();
  }
}

// Uso:
void iniciarApp() {
  final sessionManager = SessionManager();
  sessionManager.iniciarGestionDeSesion();
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 7: MANEJO DE EXCEPCIONES COMPLETO
// ══════════════════════════════════════════════════════════════════════════════════

Future<void> ejemploManejoCompleto() async {
  final authService = AuthService();

  try {
    final usuario = await authService.login(
      email: 'user@example.com',
      password: 'Password123!@#',
    );
    print('✅ Login exitoso: ${usuario.nombre}');
  } on AuthException catch (e) {
    // Errores de autenticación específicos
    switch (e.code) {
      case 'INVALID_CREDENTIALS':
        print('❌ Credenciales inválidas - mostrar diálogo al usuario');
        break;
      case 'USER_NOT_FOUND':
        print('❌ Usuario no registrado - ofrecer opción de registro');
        break;
      case 'USER_INACTIVE':
        print('❌ Cuenta desactivada - contactar soporte');
        break;
      case 'TOKEN_EXPIRED':
        print('❌ Token expirado - ir a login');
        break;
      default:
        print('❌ Error: ${e.message}');
    }
  } on ValidationException catch (e) {
    // Errores de validación - generalmente en el cliente
    switch (e.code) {
      case 'INVALID_EMAIL':
        print('⚠️ Email inválido - revisar formato');
        break;
      case 'PASSWORD_TOO_SHORT':
        print('⚠️ Contraseña muy corta');
        break;
      default:
        print('⚠️ Validación: ${e.message}');
    }
  } on NetworkException catch (e) {
    // Errores de red - servidor/internet
    print('🌐 Problema de conexión: ${e.message}');
    print('   Sugerir: Verificar conexión a internet e intentar de nuevo');
  } on StorageException catch (e) {
    // Errores de almacenamiento local - permisos del SO
    print('💾 Error de almacenamiento: ${e.message}');
    print('   Sugerir: Reiniciar app o verificar permisos');
  } on AppException catch (e) {
    // Cualquier otro error de la aplicación
    print('❌ Error: ${e.message}');
    if (e.code != null) print('   Código: ${e.code}');
  }
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 8: REQUISITOS DE CONTRASEÑA
// ══════════════════════════════════════════════════════════════════════════════════

/// Ejemplos de contraseñas VÁLIDAS
void ejemplosPasswordValidas() {
  final passwordValidas = [
    'SecurePass123!@#',      // ✅ Clásica
    'MyPassword456$%^',      // ✅ Con símbolos
    'Admin_Pass789!',        // ✅ Con guión bajo
    'P@ssw0rd2024',          // ✅ Año como número
    'Complex!P@ss999',       // ✅ Bien mezclada
  ];
  print('Contraseñas válidas:');
  for (var p in passwordValidas) {
    print('  ✅ $p');
  }
}

/// Ejemplos de contraseñas INVÁLIDAS
void ejemplosPasswordInvalidas() {
  final passwordInvalidas = [
    'short123',              // ❌ Menos de 8 caracteres
    'nouppercasehere123!',   // ❌ Sin mayúscula
    'NOLOWERCASEHERE123!',   // ❌ Sin minúscula
    'NoNumbers!',            // ❌ Sin número
    'NoSpecial123',          // ❌ Sin carácter especial
  ];
  print('Contraseñas inválidas:');
  for (var p in passwordInvalidas) {
    print('  ❌ $p');
  }
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 9: INTEGRACIÓN CON WIDGET
// ══════════════════════════════════════════════════════════════════════════════════

Future<void> mostrarDialogoLogin(BuildContext context) async {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Iniciar sesión'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passCtrl,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final user = await AuthService().login(
                email: emailCtrl.text,
                password: passCtrl.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bienvenido ${user.nombre}')),
                );
              }
            } on AppException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.message}')),
                );
              }
            }
          },
          child: const Text('Login'),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════════
// EJEMPLO 10: PROTECCIÓN DE RUTAS
// ══════════════════════════════════════════════════════════════════════════════════

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final List<String>? rolesPermitidos;

  const ProtectedRoute({
    Key? key,
    required this.child,
    this.rolesPermitidos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionInfo?>(
      future: AuthService().obtenerSesionActiva(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data;

        // Sin sesión
        if (session == null) {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink();
        }

        // Verificar rol si es necesario
        if (rolesPermitidos != null &&
            !rolesPermitidos!.contains(session.user.rol)) {
          Future.microtask(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No tienes permisos')),
            );
            Navigator.pushReplacementNamed(context, '/');
          });
          return const SizedBox.shrink();
        }

        // Sesión válida y rol ok
        return child;
      },
    );
  }
}

// Uso:
// ProtectedRoute(
//   rolesPermitidos: ['Administrador'],
//   child: AdminDashboard(),
// )

